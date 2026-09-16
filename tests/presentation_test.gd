extends SceneTree
## Rendered layout checks; run with a graphics display (not --headless).
var failures: int = 0

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	# An offscreen outer viewport allows exact sizes even under a tiling WM.
	var outer := SubViewport.new()
	outer.size = Vector2i(1708, 960)
	outer.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(outer)
	var scene = load("res://scenes/test/FlightPlayground.tscn").instantiate()
	outer.add_child(scene)
	await process_frame
	var ship = scene.get_node("GameViewport/World/PlayerShip")
	ship.set_physics_process(false)
	scene.set_process_input(false)
	ship.steering_offset = Vector2.ZERO
	ship.flight_paused = false
	for frame in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	outer.get_texture().get_image().save_png("/tmp/freestar-default.png")
	_check(scene.display_scale == 2.0, "2x scale at default size")
	# Exercise the longest mode label and four-digit boost speed at native scale.
	ship.flight_mode = PlayerShip.FlightMode.ACCELERATING
	ship.current_speed = 1200.0
	outer.size = Vector2i(1100, 700)
	for frame in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	outer.get_texture().get_image().save_png("/tmp/freestar-resized.png")
	_check(scene.display_scale == 1.0, "Integer scale at intermediate window size")
	_check(scene.screen.position == Vector2(123, 110), "Centered black bars")
	outer.size = Vector2i(640, 400)
	for frame in 8:
		await process_frame
	_check(is_equal_approx(scene.display_scale, 640.0 / 854.0), "Proportional downscale for small window")
	scene._notification(MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT)
	_check(ship.flight_paused, "Focus loss pauses flight")
	await process_frame
	await RenderingServer.frame_post_draw
	outer.get_texture().get_image().save_png("/tmp/freestar-paused.png")
	print("Presentation checks complete: %d failure(s)." % failures)
	quit(1 if failures else 0)
