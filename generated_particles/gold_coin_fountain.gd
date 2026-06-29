extends Node2D

const COIN_TEXTURE := preload("res://particle/gold_0.png")
const SPARKLE_TEXTURE := preload("res://particle/blink_0.png")

var _rng := RandomNumberGenerator.new()

@onready var _main_coins: GPUParticles2D = $MainCoins
@onready var _left_coins: GPUParticles2D = $LeftCoins
@onready var _right_coins: GPUParticles2D = $RightCoins
@onready var _coin_burst: GPUParticles2D = $CoinBurst
@onready var _sparkles: GPUParticles2D = $Sparkles
@onready var _burst_sparkles: GPUParticles2D = $BurstSparkles
@onready var _pulse_timer: Timer = $PulseTimer

func _ready() -> void:
	_rng.randomize()
	_configure_coin_stream(_main_coins, Vector2(0.0, -1.0), 16.0, 30, 1.55, 520.0, 760.0, 1180.0, Vector2(0.28, 0.36))
	_configure_coin_stream(_left_coins, Vector2(-0.18, -1.0), 12.0, 20, 1.35, 460.0, 680.0, 1100.0, Vector2(0.22, 0.30))
	_configure_coin_stream(_right_coins, Vector2(0.18, -1.0), 12.0, 20, 1.35, 460.0, 680.0, 1100.0, Vector2(0.22, 0.30))
	_configure_coin_burst(_coin_burst)
	_configure_sparkles(_sparkles, false)
	_configure_sparkles(_burst_sparkles, true)

	_main_coins.preprocess = 1.6
	_left_coins.preprocess = 1.1
	_right_coins.preprocess = 1.1
	_sparkles.preprocess = 0.8

	_pulse_timer.timeout.connect(_on_pulse_timer_timeout)
	_update_root_layout()
	if _is_standalone_scene():
		get_viewport().size_changed.connect(_update_root_layout)
	_trigger_burst()
	_schedule_next_burst()

func _configure_coin_stream(
	emitter: GPUParticles2D,
	direction_2d: Vector2,
	spread: float,
	amount: int,
	lifetime: float,
	velocity_min: float,
	velocity_max: float,
	gravity_y: float,
	scale_range: Vector2
) -> void:
	emitter.texture = COIN_TEXTURE
	emitter.amount = amount
	emitter.lifetime = lifetime
	emitter.one_shot = false
	emitter.explosiveness = 0.0
	emitter.randomness = 0.42
	emitter.fixed_fps = 60
	emitter.local_coords = true
	emitter.emitting = true
	emitter.visibility_rect = Rect2(-560.0, -900.0, 1120.0, 1300.0)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(42.0, 10.0, 0.0)
	process.direction = Vector3(direction_2d.x, direction_2d.y, 0.0).normalized()
	process.spread = spread
	process.initial_velocity_min = velocity_min
	process.initial_velocity_max = velocity_max
	process.gravity = Vector3(0.0, gravity_y, 0.0)
	process.angular_velocity_min = -520.0
	process.angular_velocity_max = 520.0
	process.orbit_velocity_min = -0.12
	process.orbit_velocity_max = 0.12
	process.linear_accel_min = 20.0
	process.linear_accel_max = 80.0
	process.damping_min = 35.0
	process.damping_max = 65.0
	process.scale_min = scale_range.x
	process.scale_max = scale_range.y
	process.scale_curve = _make_scale_curve([Vector2(0.0, 0.82), Vector2(0.55, 1.0), Vector2(1.0, 0.92)])
	process.color_ramp = _make_gradient_texture(
		[
			Color(1.0, 0.98, 0.88, 1.0),
			Color(1.0, 0.89, 0.38, 1.0),
			Color(0.92, 0.68, 0.18, 0.92),
			Color(0.85, 0.52, 0.08, 0.0),
		],
		[0.0, 0.18, 0.72, 1.0]
	)
	emitter.process_material = process

func _configure_coin_burst(emitter: GPUParticles2D) -> void:
	emitter.texture = COIN_TEXTURE
	emitter.amount = 22
	emitter.lifetime = 1.65
	emitter.one_shot = true
	emitter.explosiveness = 1.0
	emitter.randomness = 0.35
	emitter.fixed_fps = 60
	emitter.local_coords = true
	emitter.visibility_rect = Rect2(-620.0, -960.0, 1240.0, 1360.0)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(66.0, 14.0, 0.0)
	process.direction = Vector3(0.0, -1.0, 0.0)
	process.spread = 24.0
	process.initial_velocity_min = 720.0
	process.initial_velocity_max = 980.0
	process.gravity = Vector3(0.0, 1280.0, 0.0)
	process.angular_velocity_min = -760.0
	process.angular_velocity_max = 760.0
	process.scale_min = 0.26
	process.scale_max = 0.38
	process.scale_curve = _make_scale_curve([Vector2(0.0, 1.0), Vector2(0.35, 1.12), Vector2(1.0, 0.88)])
	process.color_ramp = _make_gradient_texture(
		[
			Color(1.0, 1.0, 0.94, 1.0),
			Color(1.0, 0.92, 0.42, 1.0),
			Color(0.98, 0.71, 0.18, 0.88),
			Color(0.86, 0.54, 0.10, 0.0),
		],
		[0.0, 0.2, 0.78, 1.0]
	)
	emitter.process_material = process

func _configure_sparkles(emitter: GPUParticles2D, one_shot: bool) -> void:
	emitter.texture = SPARKLE_TEXTURE
	emitter.material = _make_canvas_material(CanvasItemMaterial.BLEND_MODE_ADD)
	emitter.amount = 20 if one_shot else 28
	emitter.lifetime = 0.72 if one_shot else 0.95
	emitter.one_shot = one_shot
	emitter.explosiveness = 1.0 if one_shot else 0.0
	emitter.randomness = 0.55
	emitter.fixed_fps = 60
	emitter.local_coords = true
	emitter.emitting = not one_shot
	emitter.visibility_rect = Rect2(-640.0, -920.0, 1280.0, 1320.0)

	var process := ParticleProcessMaterial.new()
	process.particle_flag_disable_z = true
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = Vector3(92.0 if one_shot else 110.0, 18.0, 0.0)
	process.direction = Vector3(0.0, -1.0, 0.0)
	process.spread = 34.0 if one_shot else 46.0
	process.initial_velocity_min = 180.0 if one_shot else 90.0
	process.initial_velocity_max = 340.0 if one_shot else 220.0
	process.gravity = Vector3(0.0, 460.0, 0.0)
	process.scale_min = 0.12
	process.scale_max = 0.22 if one_shot else 0.18
	process.angular_velocity_min = -240.0
	process.angular_velocity_max = 240.0
	process.color_ramp = _make_gradient_texture(
		[
			Color(1.0, 0.99, 0.88, 0.0),
			Color(1.0, 0.97, 0.76, 0.95),
			Color(1.0, 0.86, 0.35, 0.72),
			Color(0.96, 0.72, 0.18, 0.0),
		],
		[0.0, 0.12, 0.62, 1.0]
	)
	emitter.process_material = process

func _on_pulse_timer_timeout() -> void:
	_trigger_burst()
	_schedule_next_burst()

func _trigger_burst() -> void:
	_coin_burst.position.x = _rng.randf_range(-26.0, 26.0)
	_burst_sparkles.position = Vector2(_rng.randf_range(-18.0, 18.0), -12.0)
	_coin_burst.restart()
	_burst_sparkles.restart()

func _schedule_next_burst() -> void:
	_pulse_timer.wait_time = _rng.randf_range(1.0, 1.45)
	_pulse_timer.start()

func _is_standalone_scene() -> bool:
	return get_tree() != null and get_tree().current_scene == self

func _update_root_layout() -> void:
	if not _is_standalone_scene():
		return
	var viewport_size := get_viewport_rect().size
	position = Vector2(viewport_size.x * 0.5, viewport_size.y * 0.42)

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
	var material := CanvasItemMaterial.new()
	material.blend_mode = blend_mode
	return material
