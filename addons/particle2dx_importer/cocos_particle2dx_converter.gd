@tool
extends RefCounted

const DEFAULT_OUTPUT_DIR := "res://converted_particles"
const SUPPORTED_IMAGE_EXTENSIONS := ["png", "jpg", "jpeg", "webp"]

var _warnings: Array[String] = []
var _error := ""

func convert_file(input_path: String, output_scene_path: String = "", options: Dictionary = {}) -> Dictionary:
	_warnings.clear()
	_error = ""

	var normalized_input := _normalize_input_path(input_path)
	if normalized_input.is_empty():
		return _fail("Input plist path is empty.")

	var plist := _parse_plist_file(normalized_input)
	if not _error.is_empty():
		return _fail(_error)
	if plist.is_empty():
		return _fail("No supported keys were found in the plist.")

	var output_path := output_scene_path
	if output_path.is_empty():
		output_path = _default_output_scene_path(normalized_input)
	output_path = _normalize_output_resource_path(output_path)
	if output_path.is_empty():
		return _fail("Output scene must be inside the project. Use a res:// path or a project-relative path.")
	if not output_path.ends_with(".tscn"):
		output_path += ".tscn"

	var overwrite := bool(options.get("overwrite", true))
	if not overwrite and ResourceLoader.exists(output_path):
		return _fail("Output scene already exists: %s" % output_path)

	var err := _ensure_parent_dir(output_path)
	if err != OK:
		return _fail("Could not create output directory for %s: %s" % [output_path, error_string(err)])

	var texture_info := _resolve_texture(plist, normalized_input, output_path, options)
	if not texture_info.get("ok", false):
		return _fail(texture_info.get("error", "Could not resolve particle texture."))

	var particles := _build_particles(plist, texture_info, options)
	var packed := PackedScene.new()
	err = packed.pack(particles)
	particles.free()
	if err != OK:
		return _fail("Could not pack particles scene: %s" % error_string(err))

	err = ResourceSaver.save(packed, output_path)
	if err != OK:
		return _fail("Could not save scene %s: %s" % [output_path, error_string(err)])

	return {
		"ok": true,
		"scene_path": output_path,
		"texture_path": texture_info.get("texture_path", ""),
		"texture_format": texture_info.get("format", ""),
		"warnings": _warnings.duplicate()
	}

func _parse_plist_file(path: String) -> Dictionary:
	var parser := XMLParser.new()
	var err := parser.open(path)
	if err != OK:
		_error = "Could not open plist %s: %s" % [path, error_string(err)]
		return {}

	var result: Dictionary = {}
	var current_key := ""
	var current_element := ""
	var text := ""
	var supported_value_elements := {
		"string": true,
		"data": true,
		"real": true,
		"integer": true
	}

	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var name := parser.get_node_name()
				if name == "key" or supported_value_elements.has(name):
					current_element = name
					text = ""
				elif name == "true" and not current_key.is_empty():
					result[current_key] = true
					current_key = ""
				elif name == "false" and not current_key.is_empty():
					result[current_key] = false
					current_key = ""
			XMLParser.NODE_TEXT:
				if not current_element.is_empty():
					text += parser.get_node_data()
			XMLParser.NODE_ELEMENT_END:
				var end_name := parser.get_node_name()
				if end_name != current_element:
					continue
				var value_text := text.strip_edges()
				if current_element == "key":
					current_key = value_text
				elif not current_key.is_empty():
					result[current_key] = _coerce_plist_value(current_element, value_text)
					current_key = ""
				current_element = ""
				text = ""

	return result

func _coerce_plist_value(element: String, value: String) -> Variant:
	match element:
		"integer":
			return value.to_int()
		"real":
			return value.to_float()
		_:
			return value

func _resolve_texture(plist: Dictionary, input_path: String, output_scene_path: String, options: Dictionary) -> Dictionary:
	if plist.has("textureImageData") and not String(plist["textureImageData"]).strip_edges().is_empty():
		var texture_output := String(options.get("texture_output", ""))
		var use_indexed_name := texture_output.is_empty()
		if texture_output.is_empty():
			texture_output = _default_texture_output_path(output_scene_path)
		texture_output = _normalize_output_resource_path(texture_output)
		if texture_output.is_empty():
			return {"ok": false, "error": "Texture output must be inside the project."}

		var err := _ensure_parent_dir(texture_output)
		if err != OK:
			return {"ok": false, "error": "Could not create texture directory %s: %s" % [texture_output.get_base_dir(), error_string(err)]}

		return _write_embedded_texture(
			String(plist["textureImageData"]),
			texture_output,
			use_indexed_name,
			options.get("editor_file_system", null)
		)

	var texture_name := String(plist.get("textureFileName", ""))
	if texture_name.is_empty():
		_warnings.append("No textureImageData or textureFileName was found. The scene will use untextured particles.")
		return {"ok": true, "texture": null, "texture_path": "", "image_size": Vector2i(32, 32), "format": ""}

	var source_texture_path := _resolve_source_texture_path(input_path, texture_name)
	if source_texture_path.is_empty():
		_warnings.append("Texture file was not found next to the plist: %s" % texture_name)
		return {"ok": true, "texture": null, "texture_path": "", "image_size": Vector2i(32, 32), "format": ""}

	var image := Image.new()
	var err := image.load(source_texture_path)
	if err != OK:
		return {"ok": false, "error": "Could not load texture %s: %s" % [source_texture_path, error_string(err)]}

	var texture := ImageTexture.create_from_image(image)
	return {
		"ok": true,
		"texture": texture,
		"texture_path": source_texture_path,
		"image_size": image.get_size(),
		"format": source_texture_path.get_extension().to_lower()
	}

func _write_embedded_texture(encoded: String, texture_output: String, use_indexed_name: bool, editor_file_system: Object = null) -> Dictionary:
	var base64_text := encoded.strip_edges()
	var raw := Marshalls.base64_to_raw(base64_text)
	if raw.is_empty():
		return {"ok": false, "error": "Embedded texture base64 data is empty or invalid."}

	var image_bytes_info := _decode_embedded_image_bytes(raw)
	var image_bytes: PackedByteArray = image_bytes_info["bytes"]
	var image := Image.new()
	var format := _load_image_from_bytes(image, image_bytes)
	if format.is_empty():
		return {"ok": false, "error": "Embedded texture data could not be decoded as PNG, JPEG, or WebP."}

	var save_path := texture_output
	if save_path.get_extension().to_lower() != format:
		save_path = save_path.get_basename() + "." + format
	if use_indexed_name:
		save_path = _unique_indexed_resource_path(save_path)

	var err := OK
	match format:
		"png":
			err = image.save_png(save_path)
			if err == OK:
				err = _sanitize_png_metadata(save_path)
		"jpg", "jpeg":
			err = image.save_jpg(save_path)
		"webp":
			err = image.save_webp(save_path)
		_:
			err = ERR_UNAVAILABLE
	if err != OK:
		return {"ok": false, "error": "Could not save decoded texture %s: %s" % [save_path, error_string(err)]}

	_import_texture_file(save_path, editor_file_system)
	var texture := _load_texture_after_import(save_path, image, editor_file_system != null)
	return {
		"ok": true,
		"texture": texture,
		"texture_path": save_path,
		"image_size": image.get_size(),
		"format": format,
		"compression": image_bytes_info.get("compression", "raw")
	}

func _decode_embedded_image_bytes(raw: PackedByteArray) -> Dictionary:
	if _looks_like_supported_image(raw):
		return {"bytes": raw, "compression": "raw"}

	var modes := [
		{"name": "gzip", "mode": FileAccess.COMPRESSION_GZIP},
		{"name": "deflate", "mode": FileAccess.COMPRESSION_DEFLATE}
	]
	for item in modes:
		var decoded := raw.decompress_dynamic(64 * 1024 * 1024, item["mode"])
		if not decoded.is_empty() and _looks_like_supported_image(decoded):
			return {"bytes": decoded, "compression": item["name"]}

	_warnings.append("Embedded texture did not advertise a known image header after decompression attempts; trying raw bytes.")
	return {"bytes": raw, "compression": "raw"}

func _looks_like_supported_image(bytes: PackedByteArray) -> bool:
	if bytes.size() >= 8:
		if bytes[0] == 0x89 and bytes[1] == 0x50 and bytes[2] == 0x4e and bytes[3] == 0x47:
			return true
	if bytes.size() >= 3:
		if bytes[0] == 0xff and bytes[1] == 0xd8 and bytes[2] == 0xff:
			return true
	if bytes.size() >= 12:
		var riff := bytes.slice(0, 4).get_string_from_ascii()
		var webp := bytes.slice(8, 12).get_string_from_ascii()
		if riff == "RIFF" and webp == "WEBP":
			return true
	return false

func _load_image_from_bytes(image: Image, bytes: PackedByteArray) -> String:
	if image.load_png_from_buffer(bytes) == OK:
		return "png"
	if image.load_jpg_from_buffer(bytes) == OK:
		return "jpg"
	if image.has_method("load_webp_from_buffer") and image.call("load_webp_from_buffer", bytes) == OK:
		return "webp"
	return ""

func _sanitize_png_metadata(path: String) -> Error:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()

	var png_bytes := file.get_buffer(file.get_length())
	file.close()
	if not _is_png_bytes(png_bytes):
		return ERR_INVALID_DATA

	var output := _png_signature()
	var offset := 8
	var found_iend := false

	while offset + 12 <= png_bytes.size():
		var length := _read_u32_be(png_bytes, offset)
		if length < 0 or offset + 12 + length > png_bytes.size():
			return ERR_INVALID_DATA

		var type_offset := offset + 4
		var chunk_type := png_bytes.slice(type_offset, type_offset + 4).get_string_from_ascii()
		var chunk_end := offset + 12 + length

		if chunk_type == "IEND":
			output.append_array(png_bytes.slice(offset, chunk_end))
			found_iend = true
			break

		if not _should_strip_png_chunk(chunk_type):
			output.append_array(png_bytes.slice(offset, chunk_end))

		offset = chunk_end

	if not found_iend:
		return ERR_INVALID_DATA

	file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_buffer(output)
	file.close()
	return OK

func _is_png_bytes(bytes: PackedByteArray) -> bool:
	var signature := _png_signature()
	if bytes.size() < signature.size():
		return false
	for index in range(signature.size()):
		if bytes[index] != signature[index]:
			return false
	return true

func _png_signature() -> PackedByteArray:
	return PackedByteArray([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])

func _should_strip_png_chunk(chunk_type: String) -> bool:
	if chunk_type == "tRNS":
		return false
	if chunk_type.is_empty():
		return true
	var first := chunk_type.substr(0, 1)
	return first == first.to_lower()

func _read_u32_be(bytes: PackedByteArray, offset: int) -> int:
	return (
		(int(bytes[offset]) << 24)
		| (int(bytes[offset + 1]) << 16)
		| (int(bytes[offset + 2]) << 8)
		| int(bytes[offset + 3])
	)

func _import_texture_file(path: String, editor_file_system: Object = null) -> void:
	if not path.begins_with("res://"):
		return

	var filesystem := editor_file_system
	if filesystem == null and Engine.is_editor_hint() and Engine.has_singleton("EditorInterface"):
		var editor_interface := Engine.get_singleton("EditorInterface")
		if editor_interface != null and editor_interface.has_method("get_resource_filesystem"):
			filesystem = editor_interface.call("get_resource_filesystem")

	if filesystem == null:
		return

	if filesystem.has_method("update_file"):
		filesystem.call("update_file", path)
	if filesystem.has_method("reimport_files"):
		filesystem.call("reimport_files", PackedStringArray([path]))

func _load_texture_after_import(path: String, fallback_image: Image, _prefer_resource_loader: bool) -> Texture2D:
	if FileAccess.file_exists("%s.import" % path):
		var loaded := ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REPLACE)
		if loaded is Texture2D:
			return loaded

	var texture := ImageTexture.create_from_image(fallback_image)
	texture.resource_path = path
	return texture

func _build_particles(plist: Dictionary, texture_info: Dictionary, options: Dictionary) -> GPUParticles2D:
	var particles := GPUParticles2D.new()
	particles.name = _safe_node_name(String(options.get("root_name", "Particle2D")))
	var is_radius_mode := int(round(_number(plist, "emitterType", 0.0))) == 1
	var base_lifetime := max(0.01, _number(plist, "particleLifespan", 1.0))
	var lifespan_variance := absf(_number(plist, "particleLifespanVariance", 0.0))
	var emitter_duration := _number(plist, "duration", -1.0)
	var has_finite_duration := emitter_duration >= 0.0
	var max_particles := max(1, int(round(_number(plist, "maxParticles", 32.0))))
	var system_lifetime: float = base_lifetime + lifespan_variance if is_radius_mode else base_lifetime
	var amount := max_particles
	if has_finite_duration:
		var emission_window := _effective_emission_window(emitter_duration)
		var emission_rate: float = float(max_particles) / base_lifetime
		amount = clampi(int(ceil(emission_rate * emission_window)), 1, max_particles)
	elif is_radius_mode and lifespan_variance > 0.0:
		amount = max(1, int(ceil(float(max_particles) * system_lifetime / base_lifetime)))
	particles.amount = amount
	particles.lifetime = max(0.01, system_lifetime)
	particles.one_shot = has_finite_duration
	if has_finite_duration:
		var emission_window := _effective_emission_window(emitter_duration)
		var explosiveness := 1.0 - clampf(emission_window / particles.lifetime, 0.0, 1.0)
		_set_if_present(particles, "explosiveness", explosiveness)
		_set_if_present(particles, "randomness", 0.0)
	if is_radius_mode or has_finite_duration:
		_set_if_present(particles, "fixed_fps", 60)
		if is_radius_mode and not particles.one_shot:
			_set_if_present(particles, "preprocess", system_lifetime)
	particles.emitting = true
	particles.process_material = _build_process_material(plist, texture_info)

	if lifespan_variance > 0.0 and not is_radius_mode:
		_set_if_present(particles, "randomness", clampf(lifespan_variance / particles.lifetime, 0.0, 1.0))

	if bool(options.get("preserve_source_position", false)):
		particles.position = Vector2(_number(plist, "sourcePositionx", 0.0), -_number(plist, "sourcePositiony", 0.0))
	else:
		var source_pos := Vector2(_number(plist, "sourcePositionx", 0.0), _number(plist, "sourcePositiony", 0.0))
		if source_pos.length() > 0.001:
			_warnings.append("sourcePosition was ignored so the converted effect can be instanced at the origin. Use --preserve-source-position to keep it.")

	var texture: Texture2D = texture_info.get("texture", null)
	if texture != null:
		particles.texture = texture

	var visibility_size := _estimate_visibility_size(plist, texture_info)
	particles.visibility_rect = Rect2(-visibility_size * 0.5, visibility_size)

	var canvas_material := _build_canvas_material(plist)
	if canvas_material != null:
		particles.material = canvas_material

	return particles

func _build_process_material(plist: Dictionary, texture_info: Dictionary) -> Material:
	var is_radius_mode := int(round(_number(plist, "emitterType", 0.0))) == 1
	if is_radius_mode:
		return _build_radius_mode_shader_material(plist, texture_info)

	var material := ParticleProcessMaterial.new()
	_set_if_present(material, "particle_flag_disable_z", true)

	var angle := _number(plist, "angle", 0.0)
	var angle_variance := absf(_number(plist, "angleVariance", 0.0))
	var direction := Vector3(cos(deg_to_rad(angle)), -sin(deg_to_rad(angle)), 0.0).normalized()
	if direction.length() < 0.001:
		direction = Vector3.RIGHT
	material.direction = direction
	material.spread = clampf(angle_variance, 0.0, 180.0)
	material.gravity = Vector3(_number(plist, "gravityx", 0.0), -_number(plist, "gravityy", 0.0), 0.0)

	var speed := _number(plist, "speed", 0.0)
	var speed_variance := absf(_number(plist, "speedVariance", 0.0))
	material.initial_velocity_min = max(0.0, speed - speed_variance)
	material.initial_velocity_max = max(material.initial_velocity_min, speed + speed_variance)

	var radial := _number(plist, "radialAcceleration", 0.0)
	var radial_variance := absf(_number(plist, "radialAccelVariance", 0.0))
	_set_min_max(material, "radial_accel", radial, radial_variance)

	var tangential := _number(plist, "tangentialAcceleration", 0.0)
	var tangential_variance := absf(_number(plist, "tangentialAccelVariance", 0.0))
	_set_min_max(material, "tangential_accel", tangential, tangential_variance)

	var start_rotation := _number(plist, "rotationStart", 0.0)
	var start_rotation_variance := absf(_number(plist, "rotationStartVariance", 0.0))
	_set_min_max(material, "angle", start_rotation, start_rotation_variance)

	var lifetime := max(0.01, _number(plist, "particleLifespan", 1.0))
	var rotation_delta_per_second: float = (_number(plist, "rotationEnd", start_rotation) - start_rotation) / lifetime
	var rotation_delta_variance: float = absf(_number(plist, "rotationEndVariance", 0.0)) / lifetime
	_set_min_max(material, "angular_velocity", rotation_delta_per_second, rotation_delta_variance)

	var source_var := Vector2(_number(plist, "sourcePositionVariancex", 0.0), _number(plist, "sourcePositionVariancey", 0.0)).abs()
	if source_var.length() > 0.001:
		material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		material.emission_box_extents = Vector3(source_var.x, source_var.y, 0.0)

	var image_size: Vector2i = texture_info.get("image_size", Vector2i(32, 32))
	var texture_pixels := float(max(1, max(image_size.x, image_size.y)))
	_apply_size_properties(material, plist, texture_pixels)
	_apply_color_properties(material, plist)

	return material

func _effective_emission_window(duration: float) -> float:
	if duration > 0.0:
		return duration
	return 1.0 / 60.0

func _build_radius_mode_shader_material(plist: Dictionary, texture_info: Dictionary) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = _radius_mode_shader_code()
	var material := ShaderMaterial.new()
	material.shader = shader

	var image_size: Vector2i = texture_info.get("image_size", Vector2i(32, 32))
	var texture_pixels := float(max(1, max(image_size.x, image_size.y)))
	var start_size := max(0.0, _number(plist, "startParticleSize", texture_pixels))
	var start_size_variance := absf(_number(plist, "startParticleSizeVariance", 0.0))
	var finish_size_raw := _number(plist, "finishParticleSize", start_size)
	var finish_size := start_size if finish_size_raw < 0.0 else max(0.0, finish_size_raw)
	var finish_size_variance := start_size_variance if finish_size_raw < 0.0 else absf(_number(plist, "finishParticleSizeVariance", 0.0))
	var source_var := Vector2(
		absf(_number(plist, "sourcePositionVariancex", 0.0)),
		absf(_number(plist, "sourcePositionVariancey", 0.0))
	)
	material.set_shader_parameter("texture_pixels", texture_pixels)
	material.set_shader_parameter("base_lifetime", max(0.01, _number(plist, "particleLifespan", 1.0)))
	material.set_shader_parameter("lifetime_variance", absf(_number(plist, "particleLifespanVariance", 0.0)))
	material.set_shader_parameter("angle_deg", _number(plist, "angle", 0.0))
	material.set_shader_parameter("angle_variance_deg", absf(_number(plist, "angleVariance", 0.0)))
	material.set_shader_parameter("max_radius", max(0.0, _number(plist, "maxRadius", 0.0)))
	material.set_shader_parameter("max_radius_variance", absf(_number(plist, "maxRadiusVariance", 0.0)))
	material.set_shader_parameter("min_radius", max(0.0, _number(plist, "minRadius", _number(plist, "maxRadius", 0.0))))
	material.set_shader_parameter("rotate_per_second_deg", _number(plist, "rotatePerSecond", 0.0))
	material.set_shader_parameter("rotate_per_second_variance_deg", absf(_number(plist, "rotatePerSecondVariance", 0.0)))
	material.set_shader_parameter("source_position_variance", source_var)
	material.set_shader_parameter("start_size", start_size)
	material.set_shader_parameter("start_size_variance", start_size_variance)
	material.set_shader_parameter("end_size", finish_size)
	material.set_shader_parameter("end_size_variance", finish_size_variance)
	material.set_shader_parameter("start_color", _color_to_vector4(_color(plist, "startColor", Color.WHITE)))
	material.set_shader_parameter("start_color_variance", _color_variance_vector(plist, "startColor"))
	material.set_shader_parameter("end_color", _color_to_vector4(_color(plist, "finishColor", Color.WHITE)))
	material.set_shader_parameter("end_color_variance", _color_variance_vector(plist, "finishColor"))
	material.set_shader_parameter("start_rotation_deg", _number(plist, "rotationStart", 0.0))
	material.set_shader_parameter("start_rotation_variance_deg", absf(_number(plist, "rotationStartVariance", 0.0)))
	material.set_shader_parameter("end_rotation_deg", _number(plist, "rotationEnd", 0.0))
	material.set_shader_parameter("end_rotation_variance_deg", absf(_number(plist, "rotationEndVariance", 0.0)))
	return material

func _radius_mode_shader_code() -> String:
	return """
shader_type particles;
render_mode disable_velocity, disable_force;

uniform float texture_pixels = 64.0;
uniform float base_lifetime = 1.0;
uniform float lifetime_variance = 0.0;
uniform float angle_deg = 0.0;
uniform float angle_variance_deg = 0.0;
uniform float max_radius : hint_range(0.0, 4096.0, 1.0) = 0.0;
uniform float max_radius_variance : hint_range(0.0, 4096.0, 1.0) = 0.0;
uniform float min_radius : hint_range(0.0, 4096.0, 1.0) = 0.0;
uniform float rotate_per_second_deg = 0.0;
uniform float rotate_per_second_variance_deg = 0.0;
uniform float start_size = 1.0;
uniform float start_size_variance = 0.0;
uniform float end_size = 1.0;
uniform float end_size_variance = 0.0;
uniform vec2 source_position_variance = vec2(0.0);
uniform vec4 start_color = vec4(1.0);
uniform vec4 start_color_variance = vec4(0.0);
uniform vec4 end_color = vec4(1.0);
uniform vec4 end_color_variance = vec4(0.0);
uniform float start_rotation_deg = 0.0;
uniform float start_rotation_variance_deg = 0.0;
uniform float end_rotation_deg = 0.0;
uniform float end_rotation_variance_deg = 0.0;

float rand_from_seed(inout uint seed) {
	seed = seed * 1664525u + 1013904223u;
	return float(seed & 0x00ffffffu) / 16777215.0;
}

float centered_rand(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}

vec4 randomize_color(vec4 color, vec4 variance, inout uint seed) {
	return clamp(color + vec4(
		centered_rand(seed) * variance.r,
		centered_rand(seed) * variance.g,
		centered_rand(seed) * variance.b,
		centered_rand(seed) * variance.a
	), vec4(0.0), vec4(1.0));
}

void process() {
	if (RESTART) {
		CUSTOM.x = 0.0;
	} else {
		CUSTOM.x += DELTA;
	}

	uint seed = RANDOM_SEED ^ (INDEX * 747796405u) ^ (NUMBER * 2891336453u);
	uint lifetime_seed = seed ^ 1177153787u;
	float particle_lifetime = max(0.01, base_lifetime + centered_rand(lifetime_seed) * lifetime_variance);
	float t = clamp(CUSTOM.x / particle_lifetime, 0.0, 1.0);

	float emit_angle = radians(angle_deg + centered_rand(seed) * angle_variance_deg);
	float radius0 = max(0.0, max_radius + centered_rand(seed) * max_radius_variance);
	float angular_speed = radians(rotate_per_second_deg + centered_rand(seed) * rotate_per_second_variance_deg);
	float particle_start_size = max(0.0, start_size + centered_rand(seed) * start_size_variance);
	float particle_end_size = max(0.0, end_size + centered_rand(seed) * end_size_variance);
	float particle_start_rotation = radians(start_rotation_deg + centered_rand(seed) * start_rotation_variance_deg);
	float particle_end_rotation = radians(end_rotation_deg + centered_rand(seed) * end_rotation_variance_deg);
	vec4 particle_start_color = randomize_color(start_color, start_color_variance, seed);
	vec4 particle_end_color = randomize_color(end_color, end_color_variance, seed);
	vec2 source_offset = vec2(
		centered_rand(seed) * source_position_variance.x,
		-centered_rand(seed) * source_position_variance.y
	);

	float radius = mix(radius0, min_radius, t);
	float angle = emit_angle + angular_speed * CUSTOM.x;
	float size_scale = mix(particle_start_size, particle_end_size, t) / max(texture_pixels, 1.0);
	if (CUSTOM.x > particle_lifetime) {
		size_scale = 0.0;
	}
	float sprite_rotation = mix(particle_start_rotation, particle_end_rotation, t);
	float c = cos(sprite_rotation);
	float s = sin(sprite_rotation);

	TRANSFORM[0] = vec4(c * size_scale, s * size_scale, 0.0, 0.0);
	TRANSFORM[1] = vec4(-s * size_scale, c * size_scale, 0.0, 0.0);
	TRANSFORM[2] = vec4(0.0, 0.0, 1.0, 0.0);
	TRANSFORM[3] = vec4(source_offset.x - cos(angle) * radius, source_offset.y + sin(angle) * radius, 0.0, 1.0);
	VELOCITY = vec3(0.0);
	COLOR = mix(particle_start_color, particle_end_color, t);
}
"""

func _apply_size_properties(material: ParticleProcessMaterial, plist: Dictionary, texture_pixels: float) -> void:
	var start_size := max(0.0, _number(plist, "startParticleSize", texture_pixels))
	var start_size_variance := absf(_number(plist, "startParticleSizeVariance", 0.0))
	var finish_size_raw := _number(plist, "finishParticleSize", start_size)
	var finish_size := start_size if finish_size_raw < 0.0 else max(0.0, finish_size_raw)
	var finish_size_variance := start_size_variance if finish_size_raw < 0.0 else absf(_number(plist, "finishParticleSizeVariance", 0.0))

	var start_range := _size_range(start_size, start_size_variance)
	var finish_range := _size_range(finish_size, finish_size_variance)
	var start_mean := ((start_range.x + start_range.y) * 0.5) / texture_pixels
	var finish_mean := ((finish_range.x + finish_range.y) * 0.5) / texture_pixels
	var start_variance_scale := ((start_range.y - start_range.x) * 0.5) / texture_pixels
	var finish_variance_scale := ((finish_range.y - finish_range.x) * 0.5) / texture_pixels
	var has_start_variance := absf(start_range.y - start_range.x) > 0.001
	var has_finish_variance := absf(finish_range.y - finish_range.x) > 0.001
	var shared_random_ratio := _fit_shared_size_random_ratio(
		start_mean,
		start_variance_scale,
		finish_mean,
		finish_variance_scale
	)
	var scale_min_factor := max(0.0, 1.0 - shared_random_ratio)
	var scale_max_factor := max(scale_min_factor, 1.0 + shared_random_ratio)
	var start_curve_scale := _fit_curve_scale_for_range(start_range, texture_pixels, scale_min_factor, scale_max_factor)
	var finish_curve_scale := _fit_curve_scale_for_range(finish_range, texture_pixels, scale_min_factor, scale_max_factor)

	material.scale_min = scale_min_factor
	material.scale_max = scale_max_factor
	_set_if_present(material, "scale_curve", _build_scale_curve(start_curve_scale, finish_curve_scale))

	if has_start_variance or has_finish_variance:
		var start_random_ratio := _random_ratio_from_mean(start_mean, start_variance_scale)
		var finish_random_ratio := _random_ratio_from_mean(finish_mean, finish_variance_scale)
		if absf(start_random_ratio - finish_random_ratio) > 0.05:
			_warnings.append("Cocos randomizes start and end particle size independently. Godot has one shared scale_min/max random range, so size variance was approximated from both endpoints.")

func _size_range(center: float, variance: float) -> Vector2:
	var low := max(0.0, center - variance)
	var high := max(low, center + variance)
	return Vector2(low, high)

func _fit_shared_size_random_ratio(start_mean: float, start_variance: float, finish_mean: float, finish_variance: float) -> float:
	var denominator := (start_mean * start_mean) + (finish_mean * finish_mean)
	if denominator <= 0.000001:
		return 0.0
	var ratio := ((start_mean * start_variance) + (finish_mean * finish_variance)) / denominator
	return clampf(ratio, 0.0, 0.999)

func _fit_curve_scale_for_range(size_range: Vector2, texture_pixels: float, scale_min_factor: float, scale_max_factor: float) -> float:
	var low_scale := size_range.x / texture_pixels
	var high_scale := size_range.y / texture_pixels
	var denominator := (scale_min_factor * scale_min_factor) + (scale_max_factor * scale_max_factor)
	if denominator <= 0.000001:
		return 0.0
	return max(0.0, ((scale_min_factor * low_scale) + (scale_max_factor * high_scale)) / denominator)

func _random_ratio_from_mean(mean: float, variance: float) -> float:
	if mean <= 0.000001:
		return 0.0
	return clampf(variance / mean, 0.0, 0.999)

func _build_scale_curve(start_scale: float, finish_scale: float) -> CurveTexture:
	var curve := Curve.new()
	curve.min_value = 0.0
	curve.max_value = max(1.0, max(start_scale, finish_scale))
	curve.add_point(Vector2(0.0, max(0.0, start_scale)))
	curve.add_point(Vector2(1.0, max(0.0, finish_scale)))
	curve.set_point_right_mode(0, Curve.TANGENT_LINEAR)
	curve.set_point_left_mode(1, Curve.TANGENT_LINEAR)
	var texture := CurveTexture.new()
	texture.curve = curve
	return texture

func _build_color_ramp(start_color: Color, finish_color: Color) -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	gradient.colors = PackedColorArray([start_color, finish_color])
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	return texture

func _apply_color_properties(material: ParticleProcessMaterial, plist: Dictionary) -> void:
	var start_color := _color(plist, "startColor", Color.WHITE)
	var finish_color := _color(plist, "finishColor", start_color)
	var start_variance := _color_variance_vector(plist, "startColor")
	var finish_variance := _color_variance_vector(plist, "finishColor")

	material.color = Color.WHITE
	_set_if_present(material, "color_ramp", _build_color_ramp(start_color, finish_color))

	if _has_color_variance(start_variance):
		_set_if_present(material, "color_initial_ramp", _build_color_initial_remap_ramp(start_color, start_variance))
		if _color_variance_needs_zero_channel_warning(start_color, start_variance):
			_warnings.append("A start color channel has variance while its base value is 0. Godot color_initial_ramp multiplies color_ramp, so that channel cannot be reproduced exactly in gravity mode.")

	if _has_color_variance(finish_variance):
		_warnings.append("Godot ParticleProcessMaterial has one random initial color ramp. finishColorVariance was approximated through the lifetime color ramp.")

func _build_color_initial_remap_ramp(base_color: Color, variance: Vector4) -> GradientTexture1D:
	var offsets := PackedFloat32Array()
	var colors := PackedColorArray()
	var sample_count := 16
	for index in range(sample_count):
		var offset := float(index) / float(sample_count - 1)
		offsets.append(offset)
		colors.append(_color_remap_factor(_sample_color_variance(base_color, variance, index), base_color))

	var gradient := Gradient.new()
	gradient.offsets = offsets
	gradient.colors = colors
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	return texture

func _sample_color_variance(base_color: Color, variance: Vector4, index: int) -> Color:
	if index == 0:
		return Color(
			clampf(base_color.r - variance.x, 0.0, 1.0),
			clampf(base_color.g - variance.y, 0.0, 1.0),
			clampf(base_color.b - variance.z, 0.0, 1.0),
			clampf(base_color.a - variance.w, 0.0, 1.0)
		)
	if index == 1:
		return Color(
			clampf(base_color.r + variance.x, 0.0, 1.0),
			clampf(base_color.g + variance.y, 0.0, 1.0),
			clampf(base_color.b + variance.z, 0.0, 1.0),
			clampf(base_color.a + variance.w, 0.0, 1.0)
		)
	return Color(
		clampf(base_color.r + _centered_sample(index, 11) * variance.x, 0.0, 1.0),
		clampf(base_color.g + _centered_sample(index, 23) * variance.y, 0.0, 1.0),
		clampf(base_color.b + _centered_sample(index, 37) * variance.z, 0.0, 1.0),
		clampf(base_color.a + _centered_sample(index, 53) * variance.w, 0.0, 1.0)
	)

func _color_remap_factor(sampled_color: Color, base_color: Color) -> Color:
	return Color(
		_color_channel_factor(sampled_color.r, base_color.r),
		_color_channel_factor(sampled_color.g, base_color.g),
		_color_channel_factor(sampled_color.b, base_color.b),
		_color_channel_factor(sampled_color.a, base_color.a)
	)

func _color_channel_factor(value: float, base: float) -> float:
	if base <= 0.0001:
		return 1.0
	return value / base

func _centered_sample(index: int, salt: int) -> float:
	return fposmod(sin(float(index * 37 + salt * 101)) * 43758.5453123, 1.0) * 2.0 - 1.0

func _has_color_variance(variance: Vector4) -> bool:
	return max(max(absf(variance.x), absf(variance.y)), max(absf(variance.z), absf(variance.w))) > 0.0001

func _color_variance_needs_zero_channel_warning(base_color: Color, variance: Vector4) -> bool:
	return (base_color.r <= 0.0001 and variance.x > 0.0001) \
		or (base_color.g <= 0.0001 and variance.y > 0.0001) \
		or (base_color.b <= 0.0001 and variance.z > 0.0001) \
		or (base_color.a <= 0.0001 and variance.w > 0.0001)

func _build_canvas_material(plist: Dictionary) -> CanvasItemMaterial:
	var source := int(round(_number(plist, "blendFuncSource", 770.0)))
	var destination := int(round(_number(plist, "blendFuncDestination", 771.0)))
	var material := CanvasItemMaterial.new()

	if source == 1 and destination == 1:
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	elif destination == 1:
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	elif source == 1 and destination == 771:
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
	else:
		material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX

	return material

func _set_min_max(object: Object, base_name: String, value: float, variance: float) -> void:
	_set_if_present(object, "%s_min" % base_name, value - variance)
	_set_if_present(object, "%s_max" % base_name, value + variance)

func _set_if_present(object: Object, property: String, value: Variant) -> void:
	for item in object.get_property_list():
		if String(item.get("name", "")) == property:
			object.set(property, value)
			return
	_warnings.append("%s does not expose property '%s' in this Godot version." % [object.get_class(), property])

func _number(plist: Dictionary, key: String, default_value: float) -> float:
	if not plist.has(key):
		return default_value
	var value: Variant = plist[key]
	match typeof(value):
		TYPE_FLOAT, TYPE_INT:
			return float(value)
		TYPE_STRING:
			return String(value).to_float()
		_:
			return default_value

func _color(plist: Dictionary, prefix: String, default_color: Color) -> Color:
	var r := _number(plist, "%sRed" % prefix, default_color.r)
	var g := _number(plist, "%sGreen" % prefix, default_color.g)
	var b := _number(plist, "%sBlue" % prefix, default_color.b)
	var a := _number(plist, "%sAlpha" % prefix, default_color.a)
	return Color(clampf(r, 0.0, 1.0), clampf(g, 0.0, 1.0), clampf(b, 0.0, 1.0), clampf(a, 0.0, 1.0))

func _color_to_vector4(color: Color) -> Vector4:
	return Vector4(color.r, color.g, color.b, color.a)

func _color_variance_vector(plist: Dictionary, prefix: String) -> Vector4:
	return Vector4(
		absf(_number(plist, "%sVarianceRed" % prefix, 0.0)),
		absf(_number(plist, "%sVarianceGreen" % prefix, 0.0)),
		absf(_number(plist, "%sVarianceBlue" % prefix, 0.0)),
		absf(_number(plist, "%sVarianceAlpha" % prefix, 0.0))
	)

func _estimate_visibility_size(plist: Dictionary, texture_info: Dictionary) -> Vector2:
	var speed := absf(_number(plist, "speed", 0.0)) + absf(_number(plist, "speedVariance", 0.0))
	var lifetime := max(0.01, _number(plist, "particleLifespan", 1.0) + absf(_number(plist, "particleLifespanVariance", 0.0)))
	var travel: float = speed * lifetime
	var source_var := Vector2(absf(_number(plist, "sourcePositionVariancex", 0.0)), absf(_number(plist, "sourcePositionVariancey", 0.0)))
	var image_size: Vector2i = texture_info.get("image_size", Vector2i(32, 32))
	var start_size := max(0.0, _number(plist, "startParticleSize", 0.0))
	var start_size_variance := absf(_number(plist, "startParticleSizeVariance", 0.0))
	var finish_size_raw := _number(plist, "finishParticleSize", start_size)
	var finish_size := start_size if finish_size_raw < 0.0 else max(0.0, finish_size_raw)
	var finish_size_variance := start_size_variance if finish_size_raw < 0.0 else absf(_number(plist, "finishParticleSizeVariance", 0.0))
	var particle_size := max(_size_range(start_size, start_size_variance).y, _size_range(finish_size, finish_size_variance).y)
	var radius_extent := 0.0
	if int(round(_number(plist, "emitterType", 0.0))) == 1:
		radius_extent = max(
			_number(plist, "maxRadius", 0.0) + absf(_number(plist, "maxRadiusVariance", 0.0)),
			_number(plist, "minRadius", 0.0)
		)
	var extent := max(128.0, radius_extent + travel + source_var.length() + particle_size + float(max(image_size.x, image_size.y)))
	return Vector2(extent * 2.0, extent * 2.0)

func _default_output_scene_path(input_path: String) -> String:
	var base_name := input_path.get_file().get_basename()
	if base_name.is_empty():
		base_name = "particle"
	return "%s/%s.tscn" % [DEFAULT_OUTPUT_DIR, base_name]

func _default_texture_output_path(output_scene_path: String) -> String:
	var particle_name := _safe_file_stem(output_scene_path.get_file().get_basename())
	if particle_name.is_empty():
		particle_name = "particle"
	return "%s/%s.png" % [output_scene_path.get_base_dir(), particle_name]

func _unique_indexed_resource_path(resource_path: String) -> String:
	var directory := resource_path.get_base_dir()
	var stem := _safe_file_stem(resource_path.get_file().get_basename())
	var extension := resource_path.get_extension().to_lower()
	if extension.is_empty() or not SUPPORTED_IMAGE_EXTENSIONS.has(extension):
		extension = "png"

	var index := 0
	while true:
		var candidate := "%s/%s_%d.%s" % [directory, stem, index, extension]
		if not FileAccess.file_exists(candidate) and not ResourceLoader.exists(candidate):
			return candidate
		index += 1
	return resource_path

func _resolve_source_texture_path(input_path: String, texture_name: String) -> String:
	if texture_name.begins_with("res://") or texture_name.begins_with("user://") or texture_name.is_absolute_path():
		return texture_name

	var local_candidate := "%s/%s" % [input_path.get_base_dir(), texture_name]
	if FileAccess.file_exists(local_candidate):
		return local_candidate

	var project_candidate := "res://%s" % texture_name.trim_prefix("/")
	if FileAccess.file_exists(project_candidate):
		return project_candidate

	return ""

func _normalize_input_path(path: String) -> String:
	var normalized := path.strip_edges().replace("\\", "/")
	if normalized.is_empty():
		return ""
	if normalized.begins_with("res://") or normalized.begins_with("user://") or normalized.is_absolute_path():
		return normalized
	return ProjectSettings.globalize_path("res://%s" % normalized.trim_prefix("/"))

func _normalize_output_resource_path(path: String) -> String:
	var normalized := path.strip_edges().replace("\\", "/")
	if normalized.is_empty():
		return ""
	if normalized.begins_with("res://"):
		return normalized
	if normalized.begins_with("user://"):
		return ""
	if not normalized.is_absolute_path():
		return "res://%s" % normalized.trim_prefix("/")

	var project_root := ProjectSettings.globalize_path("res://").replace("\\", "/").trim_suffix("/")
	if normalized == project_root:
		return "res://"
	if normalized.begins_with(project_root + "/"):
		return "res://%s" % normalized.substr(project_root.length() + 1)
	return ""

func _ensure_parent_dir(resource_path: String) -> Error:
	var dir := resource_path.get_base_dir()
	if dir.is_empty() or dir == "res://":
		return OK
	return DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))

func _safe_node_name(value: String) -> String:
	var name := value.strip_edges()
	if name.is_empty():
		return "Particle2D"
	for invalid in ["/", ":", "@", "%"]:
		name = name.replace(invalid, "_")
	return name

func _safe_file_stem(value: String) -> String:
	var stem := value.strip_edges()
	for invalid in ["/", "\\", ":", "@", "%", "*", "?", "\"", "<", ">", "|", " "]:
		stem = stem.replace(invalid, "_")
	return stem

func _fail(message: String) -> Dictionary:
	return {
		"ok": false,
		"error": message,
		"warnings": _warnings.duplicate()
	}
