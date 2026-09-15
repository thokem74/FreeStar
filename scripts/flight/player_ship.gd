class_name PlayerShip
extends CharacterBody3D
## Arcade flight: throttle requests forward speed; collisions never damage the ship.

@export_category("Flight")
@export var max_speed: float = 600.0
@export var acceleration: float = 100.0
@export var deceleration: float = 150.0
@export var throttle_change_rate: float = 0.5
@export var roll_rate_degrees: float = 100.0
@export_category("Steering")
@export var mouse_sensitivity: float = 1.0
@export var invert_pitch: bool = false
@export var steering_radius: float = 160.0
@export_range(0.0, 0.9) var steering_dead_zone: float = 0.06
@export var turn_rate_degrees: float = 90.0
@export var steering_response: float = 10.0

var throttle: float = 0.0
var steering_offset: Vector2 = Vector2.ZERO
var flight_paused: bool = false
var current_speed: float = 0.0
var _forward_speed: float = 0.0
var _angular_rate: Vector2 = Vector2.ZERO
var _spawn_transform: Transform3D

func _ready() -> void:
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	_spawn_transform = global_transform

# The root presentation routes input explicitly because this ship lives in a
# SubViewport. Mouse deltas are converted from window pixels to internal pixels.
func handle_input(event: InputEvent, display_scale: float) -> void:
	if event.is_action_pressed("pause_flight"):
		pause_flight()
		return
	if flight_paused:
		if event.is_action_pressed("resume_flight"):
			resume_flight()
		return
	if event.is_action_pressed("reset_flight"):
		reset_flight()
	if event.is_action_pressed("center_steering"):
		steering_offset = Vector2.ZERO
	if event.is_action_pressed("stop_ship"):
		throttle = 0.0
	if event is InputEventMouseMotion:
		steering_offset = (steering_offset + event.screen_relative * mouse_sensitivity / maxf(display_scale, 0.001)).limit_length(steering_radius)

func pause_flight() -> void:
	flight_paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume_flight() -> void:
	steering_offset = Vector2.ZERO
	_angular_rate = Vector2.ZERO
	flight_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func reset_flight() -> void:
	global_transform = _spawn_transform
	throttle = 0.0
	_forward_speed = 0.0
	current_speed = 0.0
	velocity = Vector3.ZERO
	steering_offset = Vector2.ZERO
	_angular_rate = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if flight_paused:
		return
	var throttle_axis: float = Input.get_axis("throttle_down", "throttle_up")
	throttle = clampf(throttle + throttle_axis * throttle_change_rate * delta, 0.0, 1.0)
	if Input.is_action_pressed("stop_ship"):
		throttle = 0.0
	_update_rotation(delta)
	var requested_speed: float = throttle * max_speed
	var change_rate: float = acceleration if requested_speed > _forward_speed else deceleration
	_forward_speed = move_toward(_forward_speed, requested_speed, change_rate * delta)
	# Godot cameras face local -Z. Rebuild velocity from this axis each tick so
	# collision sliding cannot leave persistent sideways drift in open space.
	velocity = -global_basis.z * _forward_speed
	move_and_slide()
	# Real displacement includes collision constraints, unlike the requested speed.
	current_speed = get_position_delta().length() / delta
	if get_slide_collision_count() > 0:
		_forward_speed = minf(_forward_speed, maxf(0.0, get_real_velocity().dot(-global_basis.z)))

func _update_rotation(delta: float) -> void:
	var offset: Vector2 = steering_offset / maxf(steering_radius, 0.001)
	var strength: float = clampf((offset.length() - steering_dead_zone) / (1.0 - steering_dead_zone), 0.0, 1.0)
	var desired_rate: Vector2 = offset.normalized() * strength * deg_to_rad(turn_rate_degrees)
	# Exponential smoothing gives the same response over equal elapsed time.
	_angular_rate = _angular_rate.lerp(desired_rate, 1.0 - exp(-steering_response * delta))
	var pitch_sign: float = 1.0 if invert_pitch else -1.0
	rotate_object_local(Vector3.RIGHT, _angular_rate.y * pitch_sign * delta)
	rotate_object_local(Vector3.UP, -_angular_rate.x * delta)
	rotate_object_local(Vector3.BACK, -Input.get_axis("roll_left", "roll_right") * deg_to_rad(roll_rate_degrees) * delta)
	basis = basis.orthonormalized()
