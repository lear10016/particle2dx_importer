extends Node2D

const RADIAL_GLOW_TEXTURE := preload("res://particle/radial_glow_0.png")
const BLINK_TEXTURE := preload("res://particle/blink_0.png")
const RAY_TEXTURE := preload("res://particle/ray_0.png")
const SMOKE_TEXTURE := preload("res://particle/smoke_fog_0.png")

const ELECTRIC_BLUE := Color(0.26, 0.78, 1.0, 1.0)
const ARC_BLUE := Color(0.54, 0.92, 1.0, 1.0)
const CORE_WHITE := Color(0.96, 0.99, 1.0, 1.0)
const STORM_VIOLET := Color(0.56, 0.42, 1.0, 1.0)

var _rng := RandomNumberGenerator.new()
var _time := 0.0

@onready var _motif_root: Node2D = $MotifRoot
@onready var _core_glow: Sprite2D = $CoreGlow
@onready var _charge_motes: GPUParticles2D = $ChargeMotes
@onready var _arc_shards: GPUParticles2D = $ArcShards
@onready var _rain_streaks: GPUParticles2D = $RainStreaks
@onready var _strike_burst: GPUParticles2D = $StrikeBurst
@onready var _ground_haze: GPUParticles2D = $GroundHaze
@onready var _main_bolt: Line2D = $MainBolt
@onready var _side_bolt_a: Line2D = $SideBoltA
@onready var _side_bolt_b: Line2D = $SideBoltB
@onready var _storm_pulse_timer: Timer = $StormPulseTimer

func _ready() -> void:
	_rng.randomize()
	_spawn_reference_motifs()
	_setup_core_glow()
	_configure_charge_motes()
	_configure_arc_shards()
	_configure_rain_streaks()
	_configure_strike_burst()
	_configure_ground_haze()
	_setup_bolt_line(_main_bolt, 18.0, 0.95)
	_setup_bolt_line(_side_bolt_a, 10.0, 0.72)
	_setup_bolt_line(_side_bolt_b, 9.0, 0.66)
	_update_root_layout()
	if _is_standalone_scene():
		get_viewport().size_changed.connect(_update_root_layout)
	_storm_pulse_timer.timeout.connect(_on_storm_pulse)
	_restart_all_particles()
	_trigger_storm_pulse()
	_schedule_next_pulse()

func _process(delta: float) -> void:
	_time += delta
	_motif_root.rotation += delta * 0.22
	_main_bolt.rotation = sin(_time * 0.7) * 0.03
	_side_bolt_a.rotation = -0.12 + sin(_time * 0.9) * 0.07
	_side_bolt_b.rotation = 0.15 + cos(_time * 0.8) * 0.06

	var pulse := 0.5 + 0.5 * sin(_time * 2.4)
	_core_glow.modulate = Color(0.74, 0.9, 1.0, 0.18 + pulse * 0.16)
	_core_glow.scale = Vector2.ONE * (0.56 + pulse * 0.08)

func _spawn_reference_motifs() -> void:
	var outer_ring := _create_ring_line(142.0, 8.0, Color(0.34, 0.86, 1.0, 0.52), 48, 5.0)
	outer_ring.name = "OuterRing"
	outer_ring.rotation = deg_to_rad(6.0)
	_motif_root.add_child(outer_ring)

	var inner_ring := _create_ring_line(92.0, 4.0, Color(0.74, 0.96, 1.0, 0.42), 36, 3.0)
	inner_ring.name = "InnerRing"
	inner_ring.rotation = deg_to_rad(-12.0)
	_motif_root.add_child(inner_ring)

func _setup_core_glow() -> void:
	_core_glow.texture = RADIAL_GLOW_TEXTURE
	_core_glow.centered = true
	_core_glow.modulate = Color(0.72, 0.9, 1.0, 0.28)
	_core_glow.scale = Vector2.ONE * 0.62
	_core_glow.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)

func _configure_charge_motes() -> void:
	_charge_motes.texture = BLINK_TEXTURE
	_charge_motes.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	_charge_motes.modulate = Color(0.64, 0.9, 1.0, 1.0)
	_charge_motes.amount = 28
	_charge_motes.lifetime = 1.15
	_charge_motes.preprocess = 1.15
	_charge_motes.randomness = 0.62
	_charge_motes.fixed_fps = 60
	_charge_motes.local_coords = true
	_charge_motes.visibility_rect = Rect2(-360.0, -320.0, 720.0, 640.0)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	process.emission_ring_axis = Vector3(0.0, 0.0, 1.0)
	process.emission_ring_inner_radius = 18.0
	process.emission_ring_radius = 92.0
	process.emission_ring_height = 0.0
	process.direction = Vector3(0.0, -1.0, 0.0)
	process.spread = 180.0
	process.initial_velocity_min = 42.0
	process.initial_velocity_max = 120.0
	process.radial_accel_min = -68.0
	process.radial_accel_max = -24.0
	process.tangential_accel_min = 45.0
	process.tangential_accel_max = 110.0
	process.orbit_velocity_min = -0.38
	process.orbit_velocity_max = 0.38
	process.gravity = Vector3(0.0, -22.0, 0.0)
	process.scale_min = 0.08
	process.scale_max = 0.18
	process.angular_velocity_min = -180.0
	process.angular_velocity_max = 180.0
	process.color_ramp = _make_gradient_texture(
		[
			Color(0.98, 1.0, 1.0, 0.0),
			Color(0.88, 0.98, 1.0, 0.95),
			Color(0.48, 0.84, 1.0, 0.7),
			Color(0.28, 0.44, 1.0, 0.0),
		],
		[0.0, 0.12, 0.58, 1.0]
	)
	_charge_motes.process_material = process

func _configure_arc_shards() -> void:
	_arc_shards.texture = RAY_TEXTURE
	_arc_shards.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	_arc_shards.modulate = Color(0.48, 0.84, 1.0, 0.88)
	_arc_shards.amount = 20
	_arc_shards.lifetime = 0.62
	_arc_shards.preprocess = 0.62
	_arc_shards.randomness = 0.55
	_arc_shards.fixed_fps = 60
	_arc_shards.local_coords = true
	_arc_shards.visibility_rect = Rect2(-540.0, -420.0, 1080.0, 840.0)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	process.emission_ring_axis = Vector3(0.0, 0.0, 1.0)
	process.emission_ring_inner_radius = 24.0
	process.emission_ring_radius = 156.0
	process.emission_ring_height = 0.0
	process.direction = Vector3(0.0, -1.0, 0.0)
	process.spread = 120.0
	process.initial_velocity_min = 210.0
	process.initial_velocity_max = 420.0
	process.radial_accel_min = -36.0
	process.radial_accel_max = 28.0
	process.tangential_accel_min = -52.0
	process.tangential_accel_max = 52.0
	process.gravity = Vector3(0.0, 34.0, 0.0)
	process.scale_min = 0.18
	process.scale_max = 0.38
	process.angular_velocity_min = -420.0
	process.angular_velocity_max = 420.0
	process.scale_curve = _make_scale_curve([Vector2(0.0, 0.42), Vector2(0.2, 1.0), Vector2(1.0, 0.18)])
	process.color_ramp = _make_gradient_texture(
		[
			Color(0.96, 1.0, 1.0, 0.0),
			Color(0.84, 0.98, 1.0, 0.95),
			Color(0.26, 0.82, 1.0, 0.84),
			Color(0.46, 0.34, 1.0, 0.0),
		],
		[0.0, 0.08, 0.34, 1.0]
	)
	_arc_shards.process_material = process

func _configure_rain_streaks() -> void:
	_rain_streaks.texture = RAY_TEXTURE
	_rain_streaks.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	_rain_streaks.modulate = Color(0.4, 0.78, 1.0, 0.82)
	_rain_streaks.amount = 36
	_rain_streaks.lifetime = 0.92
	_rain_streaks.preprocess = 0.92
	_rain_streaks.randomness = 0.44
	_rain_streaks.fixed_fps = 60
	_rain_streaks.local_coords = true
	_rain_streaks.visibility_rect = Rect2(-620.0, -520.0, 1240.0, 1040.0)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(172.0, 24.0, 0.0)
	process.direction = Vector3(0.0, 1.0, 0.0)
	process.spread = 18.0
	process.initial_velocity_min = 420.0
	process.initial_velocity_max = 780.0
	process.gravity = Vector3(0.0, 220.0, 0.0)
	process.angular_velocity_min = -160.0
	process.angular_velocity_max = 160.0
	process.scale_min = 0.22
	process.scale_max = 0.46
	process.scale_curve = _make_scale_curve([Vector2(0.0, 0.18), Vector2(0.16, 1.0), Vector2(1.0, 0.12)])
	process.color_ramp = _make_gradient_texture(
		[
			Color(0.92, 1.0, 1.0, 0.0),
			Color(0.78, 0.96, 1.0, 0.92),
			Color(0.28, 0.72, 1.0, 0.72),
			Color(0.28, 0.3, 0.95, 0.0),
		],
		[0.0, 0.06, 0.36, 1.0]
	)
	_rain_streaks.process_material = process

func _configure_strike_burst() -> void:
	_strike_burst.texture = RAY_TEXTURE
	_strike_burst.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	_strike_burst.modulate = Color(0.62, 0.96, 1.0, 1.0)
	_strike_burst.amount = 18
	_strike_burst.lifetime = 0.48
	_strike_burst.one_shot = true
	_strike_burst.explosiveness = 1.0
	_strike_burst.randomness = 0.28
	_strike_burst.fixed_fps = 60
	_strike_burst.local_coords = true
	_strike_burst.visibility_rect = Rect2(-520.0, -420.0, 1040.0, 840.0)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	process.emission_ring_axis = Vector3(0.0, 0.0, 1.0)
	process.emission_ring_inner_radius = 12.0
	process.emission_ring_radius = 82.0
	process.emission_ring_height = 0.0
	process.direction = Vector3(0.0, -1.0, 0.0)
	process.spread = 150.0
	process.initial_velocity_min = 320.0
	process.initial_velocity_max = 620.0
	process.radial_accel_min = -12.0
	process.radial_accel_max = 40.0
	process.gravity = Vector3(0.0, 120.0, 0.0)
	process.scale_min = 0.18
	process.scale_max = 0.36
	process.angular_velocity_min = -420.0
	process.angular_velocity_max = 420.0
	process.scale_curve = _make_scale_curve([Vector2(0.0, 0.16), Vector2(0.18, 1.0), Vector2(1.0, 0.0)])
	process.color_ramp = _make_gradient_texture(
		[
			Color(1.0, 1.0, 1.0, 0.0),
			Color(0.96, 1.0, 1.0, 1.0),
			Color(0.46, 0.88, 1.0, 0.86),
			Color(0.3, 0.32, 1.0, 0.0),
		],
		[0.0, 0.06, 0.28, 1.0]
	)
	_strike_burst.process_material = process

func _configure_ground_haze() -> void:
	_ground_haze.texture = SMOKE_TEXTURE
	_ground_haze.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	_ground_haze.modulate = Color(0.34, 0.56, 1.0, 0.44)
	_ground_haze.amount = 18
	_ground_haze.lifetime = 1.8
	_ground_haze.preprocess = 1.8
	_ground_haze.randomness = 0.5
	_ground_haze.fixed_fps = 60
	_ground_haze.local_coords = true
	_ground_haze.visibility_rect = Rect2(-640.0, -260.0, 1280.0, 520.0)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(138.0, 12.0, 0.0)
	process.direction = Vector3(0.0, -1.0, 0.0)
	process.spread = 44.0
	process.initial_velocity_min = 42.0
	process.initial_velocity_max = 96.0
	process.gravity = Vector3(0.0, -16.0, 0.0)
	process.scale_min = 0.48
	process.scale_max = 0.92
	process.angular_velocity_min = -42.0
	process.angular_velocity_max = 42.0
	process.scale_curve = _make_scale_curve([Vector2(0.0, 0.42), Vector2(0.45, 1.0), Vector2(1.0, 1.22)])
	process.color_ramp = _make_gradient_texture(
		[
			Color(0.28, 0.3, 0.72, 0.0),
			Color(0.24, 0.44, 1.0, 0.28),
			Color(0.42, 0.7, 1.0, 0.18),
			Color(0.18, 0.24, 0.48, 0.0),
		],
		[0.0, 0.14, 0.58, 1.0]
	)
	_ground_haze.process_material = process

func _setup_bolt_line(line: Line2D, width: float, max_alpha: float) -> void:
	line.width = width
	line.default_color = Color(0.88, 0.98, 1.0, 0.0)
	line.texture_mode = Line2D.LINE_TEXTURE_NONE
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.antialiased = true
	line.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	line.set_meta("max_alpha", max_alpha)

func _on_storm_pulse() -> void:
	_trigger_storm_pulse()
	_schedule_next_pulse()

func _trigger_storm_pulse() -> void:
	_strike_burst.position = Vector2(_rng.randf_range(-28.0, 28.0), _rng.randf_range(-18.0, 12.0))
	_strike_burst.restart()
	_refresh_bolt(_main_bolt, Vector2(_rng.randf_range(-20.0, 20.0), -210.0), Vector2(_rng.randf_range(-12.0, 12.0), 26.0), 7, 0.24)
	_refresh_bolt(_side_bolt_a, Vector2(-126.0 + _rng.randf_range(-20.0, 18.0), -150.0), Vector2(-24.0, 18.0), 5, 0.18)
	_refresh_bolt(_side_bolt_b, Vector2(132.0 + _rng.randf_range(-18.0, 20.0), -138.0), Vector2(28.0, 16.0), 5, 0.16)
	_pulse_motif_scales()

func _pulse_motif_scales() -> void:
	for child in _motif_root.get_children():
		if not child is Node2D:
			continue
		var node := child as Node2D
		var base_scale := node.scale
		var tween := create_tween()
		tween.tween_property(node, "scale", base_scale * 1.08, 0.08)
		tween.tween_property(node, "scale", base_scale, 0.26)

func _refresh_bolt(line: Line2D, start_point: Vector2, end_point: Vector2, segments: int, fade_time: float) -> void:
	line.points = _build_bolt_points(start_point, end_point, segments)
	var max_alpha := float(line.get_meta("max_alpha"))
	line.modulate = Color(0.68, 0.92, 1.0, 0.0)
	var tween := create_tween()
	tween.tween_property(line, "modulate:a", max_alpha, 0.03)
	tween.tween_property(line, "modulate:a", 0.0, fade_time)

func _build_bolt_points(start_point: Vector2, end_point: Vector2, segments: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	points.append(start_point)
	for i in range(1, segments):
		var t := float(i) / float(segments)
		var point := start_point.lerp(end_point, t)
		var sideways := Vector2(-(end_point - start_point).y, (end_point - start_point).x).normalized()
		point += sideways * _rng.randf_range(-18.0, 18.0) * (1.0 - absf(t - 0.5) * 1.25)
		point.y += _rng.randf_range(-8.0, 8.0)
		points.append(point)
	points.append(end_point)
	return points

func _schedule_next_pulse() -> void:
	_storm_pulse_timer.wait_time = _rng.randf_range(0.85, 1.35)
	_storm_pulse_timer.start()

func _create_ring_line(radius: float, width: float, color: Color, segments: int, jitter: float) -> Line2D:
	var line := Line2D.new()
	line.width = width
	line.default_color = color
	line.closed = true
	line.antialiased = true
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	var points := PackedVector2Array()
	for i in range(segments):
		var t := float(i) / float(segments)
		var angle := TAU * t
		var radial := radius + sin(angle * 3.0) * jitter
		points.append(Vector2.RIGHT.rotated(angle) * radial)
	line.points = points
	return line

func _restart_all_particles() -> void:
	_restart_particles_recursive(_motif_root)
	_restart_particles_recursive(self)

func _restart_particles_recursive(node: Node) -> void:
	if node is GPUParticles2D:
		var particles := node as GPUParticles2D
		particles.emitting = true
		particles.restart()
	for child in node.get_children():
		_restart_particles_recursive(child)

func _is_standalone_scene() -> bool:
	return get_tree() != null and get_tree().current_scene == self

func _update_root_layout() -> void:
	if not _is_standalone_scene():
		return
	var viewport_size := get_viewport_rect().size
	position = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.5)

func _make_gradient_texture(colors: Array[Color], offsets: Array[float]) -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
	gradient.colors = PackedColorArray(colors)
	gradient.offsets = PackedFloat32Array(offsets)
	var texture := GradientTexture1D.new()
	texture.gradient = gradient
	return texture

func _make_scale_curve(points: Array[Vector2]) -> CurveTexture:
	var curve := Curve.new()
	for point in points:
		curve.add_point(point)
	var texture := CurveTexture.new()
	texture.curve = curve
	return texture

func _make_canvas_material(blend_mode: CanvasItemMaterial.BlendMode) -> CanvasItemMaterial:
	var canvas_material := CanvasItemMaterial.new()
	canvas_material.blend_mode = blend_mode
	return canvas_material
