extends SceneTree
## Requires a graphics display. Captures the four approaches and checks GUI routing.
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _draw_frames() -> void:
	for frame in 5:
		await process_frame
	await RenderingServer.frame_post_draw

func _run() -> void:
	var outer := SubViewport.new()
	outer.size = Vector2i(1708, 960)
	outer.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(outer)
	var scene = load("res://scenes/test/FlightPlayground.tscn").instantiate()
	outer.add_child(scene)
	await process_frame
	var docking: DockingCoordinator = scene.get_node("GameViewport/World/Docking")
	var player: PlayerShip = docking.player
	scene.set_process_input(false)
	player.set_physics_process(false)
	docking.set_physics_process(false)
	player.flight_paused = false
	for station in docking.stations:
		player.global_transform = station.entrance.global_transform * Transform3D(Basis.IDENTITY, Vector3(0, 0, 650))
		docking.cleared_station = station
		docking.message = "CLEARED: " + station.display_name + " | LIMIT 100 m/s"
		await _draw_frames()
		outer.get_texture().get_image().save_png("/tmp/freestar-%s.png" % station.name)
	var station: DockingStation = docking.stations[0]
	var hud = scene.get_node("GameViewport/HUDLayer/DockingHUD")
	for viewport_size: Vector2i in [Vector2i(1708, 960), Vector2i(1100, 700), Vector2i(640, 400)]:
		outer.size = viewport_size
		docking.active_station = station
		docking.state = DockingCoordinator.State.DOCKED
		player.set_external_control(true)
		player.global_transform = station.berth.global_transform
		docking.state_changed.emit()
		await _draw_frames()
		outer.get_texture().get_image().save_png("/tmp/freestar-docked-%d.png" % viewport_size.x)
		# Feed window pixels through the real presentation router, including bars.
		var center: Vector2 = hud.launch_button.get_global_rect().get_center()
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = scene.screen.position + center * scene.display_scale
		click.global_position = click.position
		click.pressed = true
		scene._input(click)
		await process_frame
		click.pressed = false
		scene._input(click)
		await process_frame
		_check(docking.state == DockingCoordinator.State.LAUNCHING, "Launch button coordinates at %d width" % viewport_size.x)
		_check(not player.external_control and player.current_speed == 0.0, "Manual launch handoff")
	print("Docking presentation checks complete: %d failure(s)." % failures)
	quit(1 if failures else 0)
