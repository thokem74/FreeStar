extends Control
## Reads flight telemetry; all movement and input remain in the ship controller.

@export var player: PlayerShip
const INK: Color = Color("9fe5d5")
const MUTED: Color = Color("6c999e")
var _font: Font = ThemeDB.fallback_font

func _ready() -> void:
	assert(player != null, "Flight HUD requires a PlayerShip reference.")
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(player):
		return
	var center: Vector2 = size * 0.5
	# HUD and world share internal pixels, keeping the pitch/yaw steering indicator aligned.
	var aim: Vector2 = center + player.steering_offset
	draw_line(center - Vector2(5, 0), center + Vector2(5, 0), MUTED)
	draw_line(center - Vector2(0, 5), center + Vector2(0, 5), MUTED)
	draw_arc(aim, 9.0, 0.0, TAU, 16, INK, 1.0)
	draw_line(aim - Vector2(14, 0), aim - Vector2(10, 0), INK)
	draw_line(aim + Vector2(10, 0), aim + Vector2(14, 0), INK)
	# Small flat cockpit panels leave the central flight view unobstructed.
	draw_colored_polygon(PackedVector2Array([Vector2(0, 370), Vector2(100, 402), Vector2(210, 480), Vector2(0, 480)]), Color("101b28"))
	draw_colored_polygon(PackedVector2Array([Vector2(854, 370), Vector2(754, 402), Vector2(644, 480), Vector2(854, 480)]), Color("101b28"))
	draw_line(Vector2(0, 370), Vector2(100, 402), MUTED)
	draw_line(Vector2(854, 370), Vector2(754, 402), MUTED)
	_text(Vector2(22, 30), "FREESTAR / FLIGHT & DOCKING", 18, INK)
	_text(Vector2(22, 50), "0.3    FOUR-STATION TEST RANGE", 12, MUTED)
	_text(Vector2(24, 432), "%03d m/s" % roundi(player.current_speed), 22, INK)
	_text(Vector2(685, 411), "FLIGHT MODE", 12, MUTED)
	_text(Vector2(685, 436), player.get_flight_mode_label(), 16, INK)
	_text(Vector2(215, 412), "MOUSE PITCH/YAW   A/D ROLL", 12, MUTED)
	_text(Vector2(215, 429), "W ACCELERATE   S BRAKE/REVERSE", 12, MUTED)
	_text(Vector2(215, 446), "RMB+MOUSE ROLL   SHIFT BOOST", 12, MUTED)
	_text(Vector2(215, 463), "C CENTER   HOME RESET   ESC PAUSE", 12, MUTED)
	if player.flight_paused:
		draw_rect(Rect2(0, 0, 854, 480), Color(0.015, 0.025, 0.045, 0.8))
		_text(Vector2(345, 222), "FLIGHT PAUSED", 22, INK)
		_text(Vector2(303, 253), "LEFT CLICK TO RESUME", 18, INK)

func _text(at: Vector2, value: String, font_size: int, color: Color) -> void:
	draw_string(_font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
