extends SceneTree
## Integration checks using real physics frames and collisions, without addons.

var failures: int = 0
var player: PlayerShip
var world: Node3D

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

func _press(action: String) -> void:
	Input.action_press(action)

func _release(action: String) -> void:
	Input.action_release(action)

func _run() -> void:
	Engine.max_fps = 0
	world = Node3D.new()
	root.add_child(world)
	player = load("res://scenes/player/PlayerShip.tscn").instantiate()
	world.add_child(player)
	await _ticks(2)
	_check(player.current_speed == 0.0 and player.throttle == 0.0, "Starts stationary")
	_press("throttle_up")
	await _ticks(150)
	_release("throttle_up")
	_check(is_equal_approx(player.throttle, 1.0), "Throttle clamps to 100%")
	await _ticks(240)
	_check(absf(player.current_speed - 600.0) < 0.2, "Reaches speed cap with persistent throttle")
	_check(player.throttle == 1.0, "Releasing W maintains throttle")
	_press("stop_ship")
	await _ticks(260)
	_release("stop_ship")
	_check(player.current_speed < 0.01 and player.throttle == 0.0, "Space decelerates to rest")
	_press("throttle_down")
	await _ticks(5)
	_release("throttle_down")
	_check(player.throttle == 0.0, "Throttle clamps to zero")

	player.reset_flight()
	player.steering_offset = Vector2(1, 0)
	await _ticks(20)
	_check(player.basis.is_equal_approx(Basis.IDENTITY), "Steering dead zone does not turn")
	player.steering_offset = Vector2(80, -80)
	await _ticks(20)
	var forward: Vector3 = -player.basis.z
	_check(forward.x > 0.0 and forward.y > 0.0, "Right/up mouse turns right/up")
	var center_event := InputEventAction.new()
	center_event.action = "center_steering"
	center_event.pressed = true
	player.handle_input(center_event, 1.0)
	_check(player.steering_offset == Vector2.ZERO, "Center input resets reticle")
	player.reset_flight()
	_press("roll_right")
	await _ticks(20)
	_release("roll_right")
	_check(player.basis.x.y < -0.1, "Right roll rotates clockwise")

	player.throttle = 1.0
	player.pause_flight()
	var paused_transform: Transform3D = player.global_transform
	await _ticks(20)
	_check(player.global_transform == paused_transform, "Pause freezes movement")
	player.steering_offset = Vector2(50, 20)
	player.resume_flight()
	_check(player.steering_offset == Vector2.ZERO, "Resume centers steering")
	player.reset_flight()
	_check(player.global_transform == Transform3D.IDENTITY and player.throttle == 0.0 and player.velocity == Vector3.ZERO, "Reset restores safe spawn and motion")
	var motion := InputEventMouseMotion.new()
	motion.screen_relative = Vector2(80, 0)
	player.handle_input(motion, 2.0)
	_check(player.steering_offset == Vector2(40, 0), "Window mouse delta maps to internal pixels")
	motion.screen_relative = Vector2(10000, 10000)
	player.handle_input(motion, 1.0)
	_check(player.steering_offset.length() <= player.steering_radius + 0.001, "Reticle is bounded")

	# A thin wall verifies swept high-speed motion, blocking and tangential sliding.
	var wall := StaticBody3D.new()
	wall.position = Vector3(0, 0, -500)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4000, 4000, 2)
	shape.shape = box
	wall.add_child(shape)
	world.add_child(wall)
	player.reset_flight()
	player.throttle = 1.0
	player._forward_speed = 600.0
	await _ticks(90)
	_check(player.position.z > -497.2, "Full-speed contact cannot tunnel through a thin wall")
	_check(player.current_speed < 1.0 and player.throttle == 1.0, "Blocked speed is near zero while throttle persists")
	player.reset_flight()
	player.rotate_y(-PI / 4.0)
	player.throttle = 1.0
	player._forward_speed = 600.0
	await _ticks(100)
	_check(player.position.z > -497.2 and player.position.x > 500.0, "Angled contact slides along wall")
	wall.queue_free()
	await _ticks(2)

	# Compare equal elapsed time at several physics rates, including steering.
	var reference_position := Vector3.ZERO
	var reference_forward := Vector3.ZERO
	for rate: int in [30, 60, 120]:
		Engine.physics_ticks_per_second = rate
		player.reset_flight()
		player.throttle = 1.0
		player.steering_offset = Vector2(35, -15)
		await _ticks(rate * 2)
		_check(absf(player.current_speed - 200.0) < 4.0, "Acceleration over two seconds at %d Hz" % rate)
		if rate == 30:
			reference_position = player.position
			reference_forward = -player.basis.z
		else:
			_check(player.position.distance_to(reference_position) < 6.0, "Comparable travel at %d Hz" % rate)
			_check((-player.basis.z).angle_to(reference_forward) < deg_to_rad(2.0), "Comparable steering at %d Hz" % rate)
	Engine.physics_ticks_per_second = 60
	world.queue_free()
	await process_frame
	print("Flight checks complete: %d failure(s)." % failures)
	quit(1 if failures else 0)
