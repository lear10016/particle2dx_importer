extends Node2D

const TRAIL_TEXTURE := preload("res://particle/trail2_0.png")
const RAY_TEXTURE := preload("res://particle/ray_0.png")
const SMOKE_TEXTURE := preload("res://particle/smoke_fog_0.png")
const BLINK_TEXTURE := preload("res://particle/blink_0.png")

const BASE_SPEED := 960.0
const PATH_WIDTH := 1180.0
const START_X := -590.0
const END_X := 590.0
const BASE_Y := 0.0

var _rng := RandomNumberGenerator.new()
var _flight_t := 0.0
var _path_phase := 0.0

@onready var _projectile_rig: Node2D = $ProjectileRig
@onready var _shadow_glow: Sprite2D = $ProjectileRig/ShadowGlow
@onready var _body: Node2D = $ProjectileRig/Body
@onready var _trail_core: GPUParticles2D = $TrailCore
@onready var _trail_smoke: GPUParticles2D = $TrailSmoke
@onready var _trail_sparks: GPUParticles2D = $TrailSparks
@onready var _impact_burst: GPUParticles2D = $ImpactBurst
@onready var _impact_sparks: GPUParticles2D = $ImpactSparks
@onready var _reset_timer: Timer = $ResetTimer

func _ready() -> void:
	_rng.randomize()
	_build_shuriken_body()
	_setup_shadow_glow()
	_configure_trail_core()
	_configure_trail_smoke()
	_configure_trail_sparks()
	_configure_impact_burst()
	_configure_impact_sparks()
	_reset_timer.timeout.connect(_reset_flight)
	_update_root_layout()
	if _is_standalone_scene():
		get_viewport().size_changed.connect(_update_root_layout)
	_restart_particles_recursive(self)
	_reset_flight()

func _process(delta: float) -> void:
	_flight_t += delta
	_path_phase += delta * 3.8
	var x_progress := minf(_flight_t * BASE_SPEED / PATH_WIDTH, 1.0)
	var x := lerpf(START_X, END_X, x_progress)
	var arc := sin(x_progress * PI) * -92.0
	var wobble := sin(_path_phase) * 10.0
	_projectile_rig.position = Vector2(x, BASE_Y + arc + wobble)
	_update_trail_positions()
	_projectile_rig.rotation += delta * 18.0
	_body.rotation -= delta * 3.2
	_shadow_glow.scale = Vector2.ONE * (0.28 + (0.5 + 0.5 * sin(_path_phase * 0.8)) * 0.08)

	if x_progress >= 1.0 and _reset_timer.is_stopped():
		_trigger_impact()
		_reset_timer.start()

func _build_shuriken_body() -> void:
	for child in _body.get_children():
		child.queue_free()

	var blade_points := PackedVector2Array([
		Vector2(0.0, -34.0),
		Vector2(10.0, -10.0),
		Vector2(34.0, 0.0),
		Vector2(10.0, 10.0),
		Vector2(0.0, 34.0),
		Vector2(-10.0, 10.0),
		Vector2(-34.0, 0.0),
		Vector2(-10.0, -10.0),
	])

	var outer := Polygon2D.new()
	outer.polygon = blade_points
	outer.color = Color(0.16, 0.18, 0.22, 1.0)
	_body.add_child(outer)

	var inner := Polygon2D.new()
	inner.polygon = _scaled_points(blade_points, 0.74)
	inner.color = Color(0.74, 0.78, 0.84, 1.0)
	_body.add_child(inner)

	var hole := Line2D.new()
	hole.width = 6.0
	hole.default_color = Color(0.10, 0.11, 0.14, 0.95)
	hole.closed = true
	hole.antialiased = true
	hole.points = _circle_points(9.0, 18)
	_body.add_child(hole)

	var edge := Line2D.new()
	edge.width = 2.5
	edge.default_color = Color(0.94, 0.96, 1.0, 0.58)
	edge.closed = true
	edge.antialiased = true
	edge.points = _scaled_points(blade_points, 0.92)
	_body.add_child(edge)

	var cut := Line2D.new()
	cut.width = 1.5
	cut.default_color = Color(0.85, 0.89, 0.96, 0.34)
	cut.antialiased = true
	cut.points = PackedVector2Array([Vector2(-14.0, -3.0), Vector2(14.0, 3.0)])
	_body.add_child(cut)

func _setup_shadow_glow() -> void:
	_shadow_glow.texture = BLINK_TEXTURE
	_shadow_glow.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	_shadow_glow.modulate = Color(0.72, 0.88, 1.0, 0.36)
	_shadow_glow.scale = Vector2.ONE * 0.22
	_shadow_glow.centered = true

func _configure_trail_core() -> void:
	_trail_core.texture = TRAIL_TEXTURE
	_trail_core.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	_trail_core.amount = 28
	_trail_core.lifetime = 0.32
	_trail_core.randomness = 0.35
	_trail_core.fixed_fps = 60
	_trail_core.local_coords = false
	_trail_core.visibility_rect = Rect2(-900.0, -320.0, 1800.0, 640.0)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(3.0, 6.0, 0.0)
	process.direction = Vector3(-1.0, 0.0, 0.0)
	process.spread = 16.0
	process.initial_velocity_min = 120.0
	process.initial_velocity_max = 240.0
	process.gravity = Vector3(0.0, 0.0, 0.0)
	process.linear_accel_min = -80.0
	process.linear_accel_max = 20.0
	process.scale_min = 0.28
	process.scale_max = 0.54
	process.angular_velocity_min = -140.0
	process.angular_velocity_max = 140.0
	process.scale_curve = _make_scale_curve([Vector2(0.0, 0.2), Vector2(0.18, 1.0), Vector2(1.0, 0.0)])
	process.color_ramp = _make_gradient_texture(
		[
			Color(0.92, 1.0, 1.0, 0.0),
			Color(0.76, 0.92, 1.0, 0.88),
			Color(0.18, 0.96, 0.78, 0.72),
			Color(0.06, 0.48, 0.26, 0.0),
		],
		[0.0, 0.08, 0.42, 1.0]
	)
	_trail_core.process_material = process

func _configure_trail_smoke() -> void:
	_trail_smoke.texture = SMOKE_TEXTURE
	_trail_smoke.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	_trail_smoke.amount = 12
	_trail_smoke.lifetime = 0.58
	_trail_smoke.randomness = 0.42
	_trail_smoke.fixed_fps = 60
	_trail_smoke.local_coords = false
	_trail_smoke.visibility_rect = Rect2(-900.0, -360.0, 1800.0, 720.0)
	_trail_smoke.modulate = Color(0.42, 0.62, 0.52, 0.34)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(4.0, 6.0, 0.0)
	process.direction = Vector3(-1.0, 0.0, 0.0)
	process.spread = 28.0
	process.initial_velocity_min = 46.0
	process.initial_velocity_max = 110.0
	process.gravity = Vector3(0.0, 6.0, 0.0)
	process.scale_min = 0.24
	process.scale_max = 0.44
	process.angular_velocity_min = -40.0
	process.angular_velocity_max = 40.0
	process.scale_curve = _make_scale_curve([Vector2(0.0, 0.28), Vector2(0.55, 1.0), Vector2(1.0, 1.24)])
	process.color_ramp = _make_gradient_texture(
		[
			Color(0.46, 0.88, 0.72, 0.0),
			Color(0.36, 0.62, 0.50, 0.28),
			Color(0.18, 0.22, 0.18, 0.16),
			Color(0.10, 0.10, 0.10, 0.0),
		],
		[0.0, 0.12, 0.56, 1.0]
	)
	_trail_smoke.process_material = process

func _configure_trail_sparks() -> void:
	_trail_sparks.texture = RAY_TEXTURE
	_trail_sparks.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	_trail_sparks.amount = 14
	_trail_sparks.lifetime = 0.18
	_trail_sparks.randomness = 0.8
	_trail_sparks.fixed_fps = 60
	_trail_sparks.local_coords = false
	_trail_sparks.visibility_rect = Rect2(-900.0, -260.0, 1800.0, 520.0)
	_trail_sparks.modulate = Color(0.86, 1.0, 0.92, 0.92)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(2.0, 8.0, 0.0)
	process.direction = Vector3(-1.0, 0.0, 0.0)
	process.spread = 38.0
	process.initial_velocity_min = 180.0
	process.initial_velocity_max = 360.0
	process.gravity = Vector3(0.0, 10.0, 0.0)
	process.scale_min = 0.12
	process.scale_max = 0.26
	process.angular_velocity_min = -260.0
	process.angular_velocity_max = 260.0
	process.scale_curve = _make_scale_curve([Vector2(0.0, 0.2), Vector2(0.1, 1.0), Vector2(1.0, 0.0)])
	process.color_ramp = _make_gradient_texture(
		[
			Color(0.98, 1.0, 1.0, 0.0),
			Color(0.92, 1.0, 0.96, 1.0),
			Color(0.34, 0.98, 0.74, 0.64),
			Color(0.14, 0.54, 0.24, 0.0),
		],
		[0.0, 0.08, 0.32, 1.0]
	)
	_trail_sparks.process_material = process

func _configure_impact_burst() -> void:
	_impact_burst.texture = BLINK_TEXTURE
	_impact_burst.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	_impact_burst.amount = 14
	_impact_burst.lifetime = 0.24
	_impact_burst.one_shot = true
	_impact_burst.explosiveness = 1.0
	_impact_burst.randomness = 0.2
	_impact_burst.fixed_fps = 60
	_impact_burst.local_coords = false
	_impact_burst.visibility_rect = Rect2(-900.0, -400.0, 1800.0, 800.0)
	_impact_burst.modulate = Color(0.86, 1.0, 0.94, 1.0)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_RING
	process.emission_ring_axis = Vector3(0.0, 0.0, 1.0)
	process.emission_ring_inner_radius = 0.0
	process.emission_ring_radius = 12.0
	process.emission_ring_height = 0.0
	process.direction = Vector3(1.0, 0.0, 0.0)
	process.spread = 180.0
	process.initial_velocity_min = 80.0
	process.initial_velocity_max = 180.0
	process.scale_min = 0.2
	process.scale_max = 0.4
	process.color_ramp = _make_gradient_texture(
		[
			Color(0.98, 1.0, 1.0, 0.0),
			Color(0.90, 1.0, 0.95, 0.96),
			Color(0.40, 0.94, 0.72, 0.46),
			Color(0.18, 0.52, 0.24, 0.0),
		],
		[0.0, 0.06, 0.28, 1.0]
	)
	_impact_burst.process_material = process

func _configure_impact_sparks() -> void:
	_impact_sparks.texture = RAY_TEXTURE
	_impact_sparks.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	_impact_sparks.amount = 18
	_impact_sparks.lifetime = 0.28
	_impact_sparks.one_shot = true
	_impact_sparks.explosiveness = 1.0
	_impact_sparks.randomness = 0.55
	_impact_sparks.fixed_fps = 60
	_impact_sparks.local_coords = false
	_impact_sparks.visibility_rect = Rect2(-900.0, -420.0, 1800.0, 840.0)
	_impact_sparks.modulate = Color(0.90, 1.0, 0.94, 1.0)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(6.0, 10.0, 0.0)
	process.direction = Vector3(-1.0, 0.0, 0.0)
	process.spread = 64.0
	process.initial_velocity_min = 220.0
	process.initial_velocity_max = 440.0
	process.gravity = Vector3(0.0, 24.0, 0.0)
	process.scale_min = 0.12
	process.scale_max = 0.26
	process.angular_velocity_min = -340.0
	process.angular_velocity_max = 340.0
	process.scale_curve = _make_scale_curve([Vector2(0.0, 0.14), Vector2(0.12, 1.0), Vector2(1.0, 0.0)])
	process.color_ramp = _make_gradient_texture(
		[
			Color(1.0, 1.0, 1.0, 0.0),
			Color(0.92, 1.0, 0.96, 1.0),
			Color(0.34, 0.94, 0.70, 0.54),
			Color(0.16, 0.44, 0.22, 0.0),
		],
		[0.0, 0.06, 0.24, 1.0]
	)
	_impact_sparks.process_material = process

func _trigger_impact() -> void:
	_impact_burst.position = _projectile_rig.position + Vector2(18.0, 0.0)
	_impact_sparks.position = _projectile_rig.position + Vector2(18.0, 0.0)
	_impact_burst.restart()
	_impact_sparks.restart()
	_projectile_rig.visible = false

func _reset_flight() -> void:
	_flight_t = 0.0
	_path_phase = _rng.randf_range(0.0, TAU)
	_projectile_rig.visible = true
	_projectile_rig.position = Vector2(START_X, BASE_Y)
	_projectile_rig.rotation = deg_to_rad(_rng.randf_range(-12.0, 12.0))
	_body.rotation = deg_to_rad(_rng.randf_range(-8.0, 8.0))
	_update_trail_positions()
	_reset_timer.stop()
	_restart_particles_recursive(self)

func _update_trail_positions() -> void:
	var trail_anchor := _projectile_rig.position + Vector2(-14.0, 0.0)
	_trail_core.position = trail_anchor
	_trail_smoke.position = trail_anchor + Vector2(4.0, 0.0)
	_trail_sparks.position = trail_anchor + Vector2(2.0, 0.0)

func _scaled_points(points: PackedVector2Array, scale_value: float) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point in points:
		result.append(point * scale_value)
	return result

func _circle_points(radius: float, segments: int) -> PackedVector2Array:
	var result := PackedVector2Array()
	for i in range(segments):
		var angle := TAU * float(i) / float(segments)
		result.append(Vector2.RIGHT.rotated(angle) * radius)
	return result

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
	position = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.54)

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
