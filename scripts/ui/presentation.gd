extends Control
## Owns window-to-viewport scaling and input routing, not gameplay movement.

const INTERNAL_SIZE: Vector2 = Vector2(854, 480)
@onready var screen: TextureRect = $Screen
@onready var player: PlayerShip = $GameViewport/World/PlayerShip
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
	if is_instance_valid(player):
		player.handle_input(event, display_scale)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(player):
		player.pause_flight()
