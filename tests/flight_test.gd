extends SceneTree
## Integration checks on real physics ticks: controls, mode transitions and swept collisions.
var failures: int = 0
var player: PlayerShip

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _ticks(count: int) -> void:
	for tick in count:
		await physics_frame
		await process_frame

func _mode(expected: PlayerShip.FlightMode) -> void:
	_check(player.flight_mode == expected, "Expected mode: " + PlayerShip.FlightMode.keys()[expected])

func _run() -> void:
	var bindings: Dictionary = {
		"accelerate": [KEY_W], "brake_reverse": [KEY_S], "boost": [KEY_SHIFT],
		"roll_left": [KEY_A], "roll_right": [KEY_D], "center_steering": [KEY_C],
		"reset_flight": [KEY_HOME], "pause_flight": [KEY_ESCAPE],
	}
	for action: String in bindings:
		for code: int in bindings[action]:
			var key := InputEventKey.new()
			key.physical_keycode = code
			if action == "boost":
				key.location = KEY_LOCATION_LEFT
			_check(InputMap.event_is_action(key, action), "Binding " + action)
	for removed: String in ["throttle_up", "throttle_down", "stop_ship", "yaw_left", "yaw_right", "thrust_left", "thrust_right", "thrust_up", "thrust_down"]:
		_check(not InputMap.has_action(removed), "Removed action: " + removed)
	var space := InputEventKey.new()
	space.physical_keycode = KEY_SPACE
	_check(not InputMap.event_is_action(space, "brake_reverse"), "Space unbound")
	var right_mouse := InputEventMouseButton.new()
	right_mouse.button_index = MOUSE_BUTTON_RIGHT
	_check(InputMap.event_is_action(right_mouse, "mouse_roll"), "RMB modifier binding")
	var world := Node3D.new()
	root.add_child(world)
	player = load("res://scenes/player/PlayerShip.tscn").instantiate()
	world.add_child(player)
	await _ticks(2)
	_mode(PlayerShip.FlightMode.STOPPED)
	_check(player.current_speed == 0.0, "Stationary startup")
	Input.action_press("accelerate")
	await _ticks(190)
	_mode(PlayerShip.FlightMode.ACCELERATING)
	_check(absf(player.current_speed - 600.0) < 0.1, "Normal speed cap")
	Input.action_release("accelerate")
	await _ticks(100)
	_mode(PlayerShip.FlightMode.CRUISE)
	_check(absf(player.current_speed - 150.0) < 0.1, "Release W returns to cruise")
	Input.action_press("brake_reverse")
	await _ticks(5)
	_mode(PlayerShip.FlightMode.BRAKING)
	Input.action_release("brake_reverse")
	await _ticks(30)
	_mode(PlayerShip.FlightMode.STOPPED)
	_check(player.current_speed == 0.0, "Brief S tap completes stop")
	Input.action_press("brake_reverse")
	await _ticks(30)
	Input.action_release("brake_reverse")
	await _ticks(10)
	_mode(PlayerShip.FlightMode.STOPPED)
	_check(player.current_speed == 0.0, "Brake latches stationary state")
	Input.action_press("boost")
	await _ticks(190)
	_mode(PlayerShip.FlightMode.BOOST)
	_check(absf(player.current_speed - 1200.0) < 0.1, "Shift restarts from stop and reaches boost cap")
	Input.action_press("accelerate")
	await _ticks(2)
	_mode(PlayerShip.FlightMode.BOOST)
	Input.action_release("boost")
	await _ticks(125)
	_mode(PlayerShip.FlightMode.ACCELERATING)
	_check(absf(player.current_speed - 600.0) < 0.1, "Release Shift while W held returns to normal speed")
	Input.action_press("boost")
	await _ticks(95)
	Input.action_release("boost")
	Input.action_release("accelerate")
	await _ticks(215)
	_mode(PlayerShip.FlightMode.CRUISE)
	_check(absf(player.current_speed - 150.0) < 0.1, "Release boost returns to cruise")
	Input.action_press("brake_reverse")
	Input.action_press("accelerate")
	Input.action_press("boost")
	await _ticks(30)
	_mode(PlayerShip.FlightMode.REVERSING)
	_check(player._forward_speed < 0.0, "S overrides W and Shift, then reverses")
	Input.action_release("accelerate")
	Input.action_release("boost")
	Input.action_release("brake_reverse")
	Input.action_press("accelerate")
	await _ticks(30)
	Input.action_release("accelerate")
	_check(player._forward_speed > 0.0, "W restarts stopped flight")
	player.pause_flight()
	var paused_transform: Transform3D = player.global_transform
	await _ticks(10)
	_check(player.global_transform == paused_transform, "Pause freezes flight")
	player.steering_offset = Vector2(40, 40)
	player.resume_flight()
	await _ticks(2)
	_mode(PlayerShip.FlightMode.CRUISE)
	_check(player.steering_offset == Vector2.ZERO, "Resume centers steering and preserves cruise")
	player.reset_flight()
	player.pause_flight()
	player.resume_flight()
	await _ticks(2)
	_mode(PlayerShip.FlightMode.STOPPED)
	_check(player.global_transform == Transform3D.IDENTITY and player.velocity == Vector3.ZERO, "Reset clears movement and cruise")

	for offset: Vector2 in [Vector2(80, 0), Vector2(-80, 0), Vector2(0, -80), Vector2(0, 80)]:
		player.reset_flight()
		player.steering_offset = offset
		await _ticks(20)
		var forward: Vector3 = -player.basis.z
		_check(forward.x * offset.x > 0.0 if offset.x != 0.0 else forward.y * offset.y < 0.0, "Mouse pitch/yaw direction")
	for action: String in ["roll_left", "roll_right"]:
		player.reset_flight()
		Input.action_press(action)
		await _ticks(20)
		Input.action_release(action)
		_check(player.basis.x.y > 0.1 if action == "roll_left" else player.basis.x.y < -0.1, "Roll direction " + action)
	player.reset_flight()
	player.steering_offset = Vector2(1, 0)
	await _ticks(20)
	_check(player.basis.is_equal_approx(Basis.IDENTITY), "Dead zone")
	var motion := InputEventMouseMotion.new()
	motion.screen_relative = Vector2(80, 0)
	player.steering_offset = Vector2.ZERO
	player.handle_input(motion, 2.0)
	_check(player.steering_offset == Vector2(40, 0), "Scaled mouse delta")
	var center := InputEventAction.new()
	center.action = "center_steering"
	center.pressed = true
	player.handle_input(center, 1.0)
	_check(player.steering_offset == Vector2.ZERO, "Center steering")
	await _ticks(60)
	_check(player._angular_rate.length() < 0.001, "Rotation settles after centering")

	# Modifier changes must not reinterpret existing yaw as roll (or vice versa).
	player.reset_flight()
	player.steering_offset = Vector2(100, -40)
	Input.action_press("mouse_roll")
	await _ticks(1)
	_check(player.mouse_roll_active and player.steering_offset.x == 0.0 and player.steering_offset.y == -40.0, "RMB clears horizontal only")
	player.steering_offset = Vector2(160, 0)
	Input.action_press("roll_right")
	await _ticks(20)
	_check(player.basis.x.y < 0.0 and absf(player._angular_rate.z) <= deg_to_rad(player.roll_rate_degrees), "Mouse roll combines with A/D within cap")
	Input.action_release("roll_right")
	player.pause_flight()
	Input.action_release("mouse_roll")
	player.resume_flight()
	_check(not player.mouse_roll_active and player.steering_offset == Vector2.ZERO and player._angular_rate == Vector3.ZERO, "Release during pause clears modifier")
	player.reset_flight()
	Input.action_press("brake_reverse")
	await _ticks(60)
	_mode(PlayerShip.FlightMode.REVERSING)
	_check(absf(player._forward_speed + 150.0) < 0.1 and player.position.z > 0.0, "Reverse speed and direction")
	Input.action_release("brake_reverse")
	await _ticks(20)
	_mode(PlayerShip.FlightMode.STOPPED)
	_check(player.current_speed == 0.0, "Reverse release stops without cruise")
	# Test explicit zero crossing from boost and back into forward flight.
	player._forward_speed = 1200.0
	Input.action_press("brake_reverse")
	var reached_zero: bool = false
	for tick in 150:
		await _ticks(1)
		if player._forward_speed == 0.0:
			reached_zero = true
	_check(reached_zero and player._forward_speed < 0.0, "Boost to reverse passes through exact zero")
	Input.action_release("brake_reverse")
	Input.action_press("boost")
	await _ticks(60)
	_check(player._forward_speed > 0.0, "Shift cancels reverse stopping and drives forward")
	Input.action_release("boost")

	var wall := StaticBody3D.new()
	wall.position.z = -500.0
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4000, 4000, 2)
	collision.shape = shape
	wall.add_child(collision)
	world.add_child(wall)
	for speed: float in [600.0, 1200.0]:
		for angle: float in [0.0, -PI / 4.0]:
			player.reset_flight()
			player.rotate_y(angle)
			player._forward_speed = speed
			var action: String = "boost" if speed > 600.0 else "accelerate"
			Input.action_press(action)
			await _ticks(100)
			Input.action_release(action)
			_check(player.position.z > -497.2, "No tunneling at speed %d" % speed)
			if angle == 0.0:
				_check(player.current_speed < 1.0 and player._forward_speed < 1.0, "Blocked speed and stored movement remain zero")
			else:
				_check(player.position.x > 500.0, "Angled contact slides")
	wall.position.z = 100.0
	await _ticks(2)
	for angle: float in [0.0, PI / 4.0]:
		player.reset_flight()
		player.rotate_y(angle)
		Input.action_press("brake_reverse")
		await _ticks(130)
		Input.action_release("brake_reverse")
		_check(player.position.z < 97.2, "Reverse collision blocks")
		if angle == 0.0:
			_check(player.current_speed < 1.0 and absf(player._forward_speed) < 1.0, "Reverse contact stores no blocked speed")
		else:
			_check(player.position.x > 100.0, "Reverse angled contact slides")
	wall.queue_free()
	await _ticks(2)
	var reference_position := Vector3.ZERO
	var reference_basis := Basis.IDENTITY
	for rate: int in [30, 60, 120]:
		Engine.physics_ticks_per_second = rate
		player.reset_flight()
		player.steering_offset = Vector2(35, -15)
		Input.action_press("boost")
		Input.action_press("roll_right")
		await _ticks(rate * 2)
		Input.action_release("boost")
		Input.action_release("roll_right")
		_check(absf(player.current_speed - 800.0) < 14.0, "Boost acceleration at %d Hz" % rate)
		if rate == 30:
			reference_position = player.position
			reference_basis = player.basis
		else:
			_check(player.position.distance_to(reference_position) < 16.0, "Comparable travel at %d Hz" % rate)
			_check(player.basis.get_rotation_quaternion().angle_to(reference_basis.get_rotation_quaternion()) < deg_to_rad(2.0), "Comparable steering at %d Hz" % rate)
	Engine.physics_ticks_per_second = 60
	world.queue_free()
	await process_frame
	print("Flight checks complete: %d failure(s)." % failures)
	quit(1 if failures else 0)
