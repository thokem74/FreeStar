extends SceneTree
## Real-scene checks for entrance history, assisted flight, all four bays and UI handoffs.
var failures: int = 0
var scene: Control
var docking: DockingCoordinator
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

func _place(station: DockingStation, point: Vector3, outward: bool = false) -> void:
	player.clear_motion()
	player.global_transform = station.entrance.global_transform * Transform3D(Basis(Vector3.UP, PI if outward else 0.0), point)

func _wait_state(expected: DockingCoordinator.State, maximum: int) -> bool:
	for tick in maximum:
		if docking.state == expected:
			return true
		await _ticks(1)
	return docking.state == expected

func _run() -> void:
	scene = load("res://scenes/test/FlightPlayground.tscn").instantiate()
	root.add_child(scene)
	docking = scene.get_node("GameViewport/World/Docking")
	player = docking.player
	await _ticks(3)
	_check(docking.stations.size() == 4, "Four valid stations")
	var request := InputEventKey.new()
	request.physical_keycode = KEY_F
	_check(InputMap.event_is_action(request, "request_docking"), "F docking binding")

	for station in docking.stations:
		print("Checking ", station.marker_name)
		_check(station.contains(station.approach_volume, station.entrance.to_global(Vector3(0, 0, 999))), "Inside 1,000 m boundary")
		_check(not station.contains(station.approach_volume, station.entrance.to_global(Vector3(0, 0, 1001))), "Outside 1,000 m boundary")
		docking.reset_docking()
		_place(station, Vector3(0, 0, 120))
		await _ticks(2)
		docking.request_clearance()
		_check(docking.cleared_station == station, "Nearest entrance receives clearance")
		docking.request_clearance()
		_check(docking.cleared_station == null, "F toggles cancellation")
		docking.request_clearance()
		await _ticks(2)
		_check(player.approach_speed_limit == 100.0, "Approach assistance engages")
		# Bypass the entrance before requesting: interior presence is insufficient.
		docking.clearance_off("TEST")
		_place(station, station.to_local(station.capture_volume.global_position))
		await _ticks(2)
		docking.request_clearance()
		await _ticks(3)
		_check(docking.state == DockingCoordinator.State.FLIGHT, "No capture from inside without entrance history")
		# A real manual approach crosses the entrance and reaches the capture zone.
		_place(station, Vector3(0, 0, 120))
		await _ticks(2)
		Input.action_press("accelerate")
		var captured: bool = await _wait_state(DockingCoordinator.State.AUTODOCK, 500)
		Input.action_release("accelerate")
		_check(captured, "Valid approach captures at " + station.marker_name)
		if not captured:
			continue
		var frozen: Transform3D = player.global_transform
		player.pause_flight()
		await _ticks(5)
		_check(player.global_transform == frozen, "Pause freezes autodock")
		player.resume_flight()
		_check(await _wait_state(DockingCoordinator.State.DOCKED, 150), "Autodock reaches berth")
		_check(player.external_control and player.current_speed == 0.0, "Docked ship cannot fly")
		_check(player.global_position.distance_to(station.berth.global_position) < 0.01, "Exact berth")
		_check((-player.global_basis.z).dot(station.entrance.global_basis.z) > 0.99, "Berth faces exit")
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		_check(docking.handle_input(click) and player.external_control, "Docked click cannot resume flight")
		docking.launch()
		_check(docking.state == DockingCoordinator.State.LAUNCHING and not player.external_control and player.current_speed == 0.0, "Launch hands off stationary ship")
		Input.action_press("accelerate")
		for tick in 400:
			if station.entrance.to_local(player.global_position).z > 30.0:
				break
			await _ticks(1)
		Input.action_release("accelerate")
		_check(station.entrance.to_local(player.global_position).z > 30.0, "Manual exit is collision-free")
		_check(docking.state == DockingCoordinator.State.LAUNCHING and player.approach_speed_limit == 100, "No immediate recapture")
		_place(station, Vector3(0, 0, 1100), true)
		await _ticks(2)
		_check(docking.state == DockingCoordinator.State.FLIGHT and player.approach_speed_limit == 0.0, "Leaving approach restores flight")
		docking.request_clearance()
		_check(docking.cleared_station == station, "Fresh clearance after launch")
		_place(station, Vector3(0, 0, 2300))
		await _ticks(2)
		_check(docking.cleared_station == null and player.approach_speed_limit == 0.0, "Range revocation")

	var station: DockingStation = docking.stations[3]
	docking.reset_docking()
	_place(station, Vector3(0, 0, 100))
	await _ticks(2)
	docking.request_clearance()
	# Roof/wall entry never crosses the entrance plane inside its aperture.
	_place(station, Vector3(0, 100, -140))
	await _ticks(2)
	_place(station, station.to_local(station.capture_volume.global_position))
	await _ticks(2)
	_check(not docking._entered and docking.state == DockingCoordinator.State.FLIGHT, "Open roof bypass rejected")
	# Record a proper entrance crossing, then reject bad capture conditions.
	_place(station, Vector3(0, 0, 5))
	await _ticks(2)
	_place(station, Vector3(0, 0, -5))
	await _ticks(2)
	_check(docking._entered, "Crossing aperture records entry")
	_place(station, station.to_local(station.capture_volume.global_position), true)
	await _ticks(2)
	_check(docking.state == DockingCoordinator.State.FLIGHT, "Backward alignment rejected")
	_place(station, station.to_local(station.capture_volume.global_position))
	player._forward_speed = 500.0
	await _ticks(1)
	_check(docking.state == DockingCoordinator.State.FLIGHT, "Overspeed capture rejected")
	# Occlude the berth to test collision sweep validation independently of entry.
	var blocker := StaticBody3D.new()
	var shape_node := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(10, 10, 10)
	shape_node.shape = box
	blocker.add_child(shape_node)
	station.add_child(blocker)
	blocker.global_position = station.berth.global_position
	await _ticks(2)
	_check(not docking._path_clear(station.capture_volume.global_position, station.berth.global_position), "Obstructed berth rejected")
	blocker.queue_free()
	docking.reset_docking()
	_place(station, Vector3(0, 0, 990))
	player._forward_speed = player.max_speed
	await _ticks(2)
	docking.request_clearance()
	Input.action_press("boost")
	await _ticks(120)
	Input.action_release("boost")
	_check(player.current_speed <= 100.1 and station.entrance.to_local(player.global_position).z > 0, "Normal-speed approach slows safely; boost remains disabled")
	player._forward_speed = -150.0
	await _ticks(10)
	_check(absf(player._forward_speed) <= 100.1, "Reverse assistance cap")
	# Clearance transfer is exclusive even if a test reposition changes nearest station.
	_place(docking.stations[0], Vector3(0, 0, 200))
	docking.request_clearance()
	_check(docking.cleared_station == docking.stations[0], "Clearance transfer")
	docking.reset_docking()
	_check(docking.cleared_station == null and docking.active_station == null and not player.external_control, "Reset clears docking state")
	scene.queue_free()
	await process_frame
	print("Docking checks complete: %d failure(s)." % failures)
	quit(1 if failures else 0)
