extends Control
## World markers share the low-resolution viewport with the cockpit.
## The docked panel is ordinary Godot GUI; presentation forwards scaled UI input.
@export var coordinator: DockingCoordinator
@export var camera: Camera3D
@onready var panel: PanelContainer = $DockedPanel
@onready var station_label: Label = $DockedPanel/Contents/StationName
@onready var launch_button: Button = $DockedPanel/Contents/Launch
var _font: Font = ThemeDB.fallback_font

func _ready() -> void:
	assert(coordinator != null and camera != null, "Docking HUD needs coordinator and camera.")
	coordinator.state_changed.connect(_refresh_panel)
	launch_button.pressed.connect(coordinator.launch)
	_refresh_panel()

func _refresh_panel() -> void:
	panel.visible = coordinator.state == DockingCoordinator.State.DOCKED
	if panel.visible:
		station_label.text = coordinator.active_station.display_name
		launch_button.grab_focus()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if coordinator == null or camera == null:
		return
	if coordinator.player.flight_paused:
		return
	if coordinator.state == DockingCoordinator.State.DOCKED:
		draw_rect(Rect2(0, 0, 854, 480), Color(0.02, 0.035, 0.055, 0.55))
		return
	var occupied: Array[Vector2] = []
	for station in coordinator.stations:
		var target: Vector3 = station.entrance.global_position
		var local: Vector3 = camera.to_local(target)
		var point: Vector2 = camera.unproject_position(target) if local.z < -0.1 else Vector2(-1000, -1000)
		var onscreen: bool = Rect2(95, 110, 664, 245).has_point(point)
		if not onscreen:
			var direction := Vector2(local.x, -local.y)
			if direction.length_squared() < 0.01:
				direction = Vector2.DOWN
			direction = direction.normalized()
			point = Vector2(427, 240) + direction * minf(325.0 / maxf(absf(direction.x), 0.001), 112.0 / maxf(absf(direction.y), 0.001))
			var side: Vector2 = direction.orthogonal() * 4.0
			draw_line(point, point - direction * 8.0 + side, station.marker_color, 2)
			draw_line(point, point - direction * 8.0 - side, station.marker_color, 2)
		else:
			draw_arc(point, 6, 0, TAU, 12, station.marker_color)
		var label_position: Vector2 = point + Vector2(-68, 18)
		for previous in occupied:
			if label_position.distance_to(previous) < 38:
				label_position.y += 30
		occupied.append(label_position)
		var cleared: bool = station == coordinator.cleared_station
		var color: Color = Color("b5ffe1") if cleared else station.marker_color
		var distance: float = coordinator.player.global_position.distance_to(target)
		draw_string(_font, label_position, station.marker_name + (" [CLR]" if cleared else ""), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)
		draw_string(_font, label_position + Vector2(0, 13), "%.1f km" % (distance / 1000.0), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, color)
		if cleared and local.z < 0 and distance < 800:
			_draw_entrance(station)
	draw_rect(Rect2(16, 65, 822, 30), Color(0.02, 0.04, 0.06, 0.9))
	draw_string(_font, Vector2(26, 85), coordinator.message, HORIZONTAL_ALIGNMENT_LEFT, 798, 13, Color("b5ffe1"))

func _draw_entrance(station: DockingStation) -> void:
	var corners: PackedVector2Array = []
	for corner in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(-1, -1)]:
		var world: Vector3 = station.entrance.to_global(Vector3(corner.x * station.entrance_half_size.x, corner.y * station.entrance_half_size.y, 0))
		if camera.is_position_behind(world):
			return
		corners.append(camera.unproject_position(world))
	draw_polyline(corners, Color("b5ffe1"), 1.0)
