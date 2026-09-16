extends Control
## Owns window-to-viewport scaling and input routing, not gameplay movement.

const INTERNAL_SIZE: Vector2 = Vector2(854, 480)
@onready var screen: TextureRect = $Screen
@onready var player: PlayerShip = $GameViewport/World/PlayerShip
@onready var docking: DockingCoordinator = $GameViewport/World/Docking
@onready var game_viewport: SubViewport = $GameViewport
var display_scale: float = 1.0

func _ready() -> void:
	get_viewport().size_changed.connect(_resize_presentation)
	_resize_presentation()
	player.resume_flight()

func _resize_presentation() -> void:
	var available: Vector2 = get_viewport_rect().size
	var fit: float = minf(available.x / INTERNAL_SIZE.x, available.y / INTERNAL_SIZE.y)
	display_scale = floorf(fit) if fit >= 1.0 else fit
	screen.size = INTERNAL_SIZE * display_scale
	screen.position = ((available - screen.size) * 0.5).floor()

func _input(event: InputEvent) -> void:
	if not is_instance_valid(player):
		return
	if event.is_action_pressed("reset_flight"):
		docking.handle_input(event)
		return
	if docking.state == DockingCoordinator.State.DOCKED:
		# SubViewport textures do not forward GUI input automatically. Translate
		# window coordinates through the same black-bar offset and scale as drawing.
		var forwarded: InputEvent = event.duplicate()
		if event is InputEventMouse:
			if not Rect2(screen.position, screen.size).has_point(event.position):
				return
			forwarded.position = (event.position - screen.position) / display_scale
			forwarded.global_position = forwarded.position
			if forwarded is InputEventMouseMotion:
				forwarded.relative /= display_scale
		game_viewport.push_input(forwarded, true)
		return
	if not docking.handle_input(event):
		player.handle_input(event, display_scale)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(player):
		if not is_instance_valid(docking) or docking.state != DockingCoordinator.State.DOCKED:
			player.pause_flight()
