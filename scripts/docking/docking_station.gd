class_name DockingStation
extends Node3D
## Station-local convention: entrance is z=0, interior is -Z, exit is +Z.
## Geometry and volumes are authored per layout; this component checks their bounds.

@export var display_name: String = "Station"
@export var marker_name: String = "STATION"
@export var marker_color: Color = Color.CYAN
@export var entrance: Marker3D
@export var berth: Marker3D
@export var approach_volume: CollisionShape3D
@export var interior_volume: CollisionShape3D
@export var capture_volume: CollisionShape3D
@export var request_range: float = 2000.0
@export var revoke_range: float = 2200.0
@export var assisted_speed: float = 100.0
@export var alignment_degrees: float = 30.0
@export var autodock_seconds: float = 2.0
@export var entrance_half_size: Vector2 = Vector2(50, 50)
var configured: bool = false

func _ready() -> void:
	configured = entrance != null and berth != null
	for volume in [approach_volume, interior_volume, capture_volume]:
		configured = configured and volume != null
		if volume != null:
			configured = configured and volume.shape is BoxShape3D
	if not configured:
		push_error("Docking station '%s' needs entrance, berth and three box volumes." % display_name)

func contains(volume: CollisionShape3D, point: Vector3, inset: float = 0.0) -> bool:
	if not configured:
		return false
	var half: Vector3 = (volume.shape as BoxShape3D).size * 0.5 - Vector3.ONE * inset
	var local: Vector3 = volume.to_local(point).abs()
	return local.x <= half.x and local.y <= half.y and local.z <= half.z

func crossed_entrance(previous: Vector3, current: Vector3, hull_radius: float) -> bool:
	var before: Vector3 = entrance.to_local(previous)
	var after: Vector3 = entrance.to_local(current)
	if before.z <= 0.0 or after.z > 0.0:
		return false
	# Test the actual crossing point, not just the frame's final position.
	var crossing: Vector3 = before.lerp(after, before.z / (before.z - after.z))
	return absf(crossing.x) <= entrance_half_size.x - hull_radius and absf(crossing.y) <= entrance_half_size.y - hull_radius

func facing_inward(forward: Vector3) -> bool:
	return forward.dot(-entrance.global_basis.z) >= cos(deg_to_rad(alignment_degrees))
