class_name PlayerShip
extends CharacterBody3D
## Assisted arcade flight: held acceleration/boost, automatic cruise, and latched stops.

@export_category("Flight")
@export var max_speed: float = 600.0
@export var cruise_speed: float = 150.0
@export var boost_speed: float = 1200.0
@export var acceleration: float = 200.0
@export var boost_acceleration: float = 400.0
@export var deceleration: float = 300.0
@export var brake_deceleration: float = 600.0
@export var roll_rate_degrees: float = 100.0
@export_category("Steering")
@export var mouse_sensitivity: float = 1.0
@export var invert_pitch: bool = false
@export var steering_radius: float = 160.0
@export_range(0.0, 0.9) var steering_dead_zone: float = 0.06
@export var turn_rate_degrees: float = 90.0
@export var steering_response: float = 10.0

enum FlightMode { STOPPED, CRUISE, ACCELERATING, BRAKING, BOOST }

var flight_mode: FlightMode = FlightMode.STOPPED
var _cruise_active: bool = false
var steering_offset: Vector2 = Vector2.ZERO
var flight_paused: bool = false
var current_speed: float = 0.0
var _forward_speed: float = 0.0
# Local pitch, yaw and roll rates, in radians per second.
var _angular_rate: Vector3 = Vector3.ZERO
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
	if event is InputEventMouseMotion:
		steering_offset = (steering_offset + event.screen_relative * mouse_sensitivity / maxf(display_scale, 0.001)).limit_length(steering_radius)

func pause_flight() -> void:
	flight_paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume_flight() -> void:
	steering_offset = Vector2.ZERO
	_angular_rate = Vector3.ZERO
	flight_paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func reset_flight() -> void:
	global_transform = _spawn_transform
	_cruise_active = false
	flight_mode = FlightMode.STOPPED
	_forward_speed = 0.0
	current_speed = 0.0
	velocity = Vector3.ZERO
	steering_offset = Vector2.ZERO
	_angular_rate = Vector3.ZERO

func _physics_process(delta: float) -> void:
	if flight_paused:
		return
	_update_rotation(delta)
	_update_speed(delta)
	# Local -Z is forward. Rebuilding velocity each tick removes lasting sideways
	# drift while still allowing the collision solver to slide along structures.
	velocity = -global_basis.z * _forward_speed
	move_and_slide()
	current_speed = get_position_delta().length() / delta
	if get_slide_collision_count() > 0:
		# Floating-mode move_and_slide can leave velocity unchanged at a head-on
		# stop. Remove components entering contact surfaces before feeding speed
		# back, so the ship cannot store pre-impact acceleration against a wall.
		var unblocked_velocity: Vector3 = velocity
		for index in get_slide_collision_count():
			var normal: Vector3 = get_slide_collision(index).get_normal()
			if unblocked_velocity.dot(normal) < 0.0:
				unblocked_velocity = unblocked_velocity.slide(normal)
		_forward_speed = clampf(unblocked_velocity.dot(-global_basis.z), 0.0, boost_speed)
		if flight_mode == FlightMode.BRAKING and is_zero_approx(_forward_speed):
			_cruise_active = false
			flight_mode = FlightMode.STOPPED

func _update_speed(delta: float) -> void:
	var braking: bool = Input.is_action_pressed("brake")
	var boosting: bool = Input.is_action_pressed("boost")
	var accelerating: bool = Input.is_action_pressed("accelerate")
	var requested_speed: float = 0.0
	var speeding_up: float = acceleration
	# Braking overrides both acceleration inputs. Reaching zero latches a stop;
	# releasing the brake early leaves cruise active. Only W/Shift reactivates it.
	if braking:
		flight_mode = FlightMode.BRAKING
	elif boosting:
		_cruise_active = true
		requested_speed = boost_speed
		speeding_up = boost_acceleration
		flight_mode = FlightMode.BOOST
	elif accelerating:
		_cruise_active = true
		requested_speed = max_speed
		flight_mode = FlightMode.ACCELERATING
	elif _cruise_active:
		requested_speed = cruise_speed
		flight_mode = FlightMode.CRUISE
	else:
		flight_mode = FlightMode.STOPPED
	var slowing_down: float = brake_deceleration if braking else deceleration
	var change_rate: float = speeding_up if requested_speed > _forward_speed else slowing_down
	_forward_speed = move_toward(_forward_speed, requested_speed, change_rate * delta)
	if braking and is_zero_approx(_forward_speed):
		_cruise_active = false
		flight_mode = FlightMode.STOPPED

func get_flight_mode_label() -> String:
	return FlightMode.keys()[flight_mode]

func _update_rotation(delta: float) -> void:
	var offset: Vector2 = steering_offset / maxf(steering_radius, 0.001)
	var strength: float = clampf((offset.length() - steering_dead_zone) / (1.0 - steering_dead_zone), 0.0, 1.0)
	var mouse_request: Vector2 = offset.normalized() * strength
	var pitch_sign: float = 1.0 if invert_pitch else -1.0
	var desired_rate := Vector3(
		mouse_request.y * pitch_sign * deg_to_rad(turn_rate_degrees),
		-mouse_request.x * deg_to_rad(turn_rate_degrees),
		-Input.get_axis("roll_left", "roll_right") * deg_to_rad(roll_rate_degrees)
	)
	# Integrate the smoothed rate over this tick instead of applying its end value
	# to the entire tick. This keeps combined turning consistent at different rates.
	var response: float = maxf(steering_response, 0.001)
	var blend: float = 1.0 - exp(-response * delta)
	var rotation_step: Vector3 = desired_rate * delta + (_angular_rate - desired_rate) * blend / response
	_angular_rate = _angular_rate.lerp(desired_rate, blend)
	# Apply simultaneous local pitch/yaw/roll as one rotation, avoiding an
	# order-dependent sequence of Euler rotations when several axes are active.
	var angle: float = rotation_step.length()
	if angle > 0.0:
		basis = (basis * Basis(rotation_step / angle, angle)).orthonormalized()
