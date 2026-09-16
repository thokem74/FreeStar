class_name DockingCoordinator
extends Node
## Owns clearance and control handoffs. Flight pause remains independent of docking.
signal state_changed

enum State { FLIGHT, AUTODOCK, DOCKED, LAUNCHING }
@export var player: PlayerShip
@export var station_root: Node3D
@export var hull: CollisionShape3D
var stations: Array[DockingStation] = []
var state: State = State.FLIGHT
var cleared_station: DockingStation
var active_station: DockingStation
var message: String = "F: REQUEST DOCKING NEAR A STATION"
var _entered: bool = false
var _previous_position: Vector3
var _autodock_start: Transform3D
var _autodock_elapsed: float = 0.0
var _message_seconds: float = 0.0

func _ready() -> void:
	assert(player != null and station_root != null and hull != null, "Docking coordinator requires player, hull and station root.")
	for child in station_root.get_children():
		if child is DockingStation and child.configured:
			stations.append(child)
	_previous_position = player.global_position
	# Observe the completed flight move, then apply assistance for the next tick.
	process_physics_priority = 1

func nearest_station() -> DockingStation:
	var nearest: DockingStation
	var distance: float = INF
	for station in stations:
		var candidate: float = player.global_position.distance_to(station.entrance.global_position)
		if candidate <= station.request_range and candidate < distance:
			nearest = station
			distance = candidate
	return nearest

func handle_input(event: InputEvent) -> bool:
	if event.is_action_pressed("reset_flight"):
		reset_docking()
		return true
	if state == State.DOCKED:
		return true
	if event.is_action_pressed("request_docking"):
		if not player.flight_paused and state == State.FLIGHT:
			request_clearance()
		return true
	return false

func request_clearance() -> void:
	var station: DockingStation = nearest_station()
	if station == null:
		_notice("NO STATION WITHIN 2,000 m")
		return
	if station == cleared_station:
		clearance_off("CLEARANCE CANCELLED")
		return
	cleared_station = station
	_entered = false
	_previous_position = player.global_position
	_notice("CLEARED: %s | ENTER THROUGH THE MARKED ENTRANCE" % station.display_name)
	state_changed.emit()

func clearance_off(reason: String) -> void:
	cleared_station = null
	_entered = false
	player.set_approach_speed_limit(0.0)
	_notice(reason)
	state_changed.emit()

func reset_docking() -> void:
	state = State.FLIGHT
	active_station = null
	cleared_station = null
	_entered = false
	_autodock_elapsed = 0.0
	player.set_external_control(false)
	player.set_approach_speed_limit(0.0)
	player.reset_flight()
	player.resume_flight()
	_previous_position = player.global_position
	_notice("FLIGHT RESET")
	state_changed.emit()

func launch() -> void:
	if state != State.DOCKED:
		return
	state = State.LAUNCHING
	cleared_station = null
	_entered = false
	player.set_external_control(false)
	player.set_approach_speed_limit(active_station.assisted_speed)
	player.resume_flight()
	_previous_position = player.global_position
	_notice("MANUAL LAUNCH | W TO DEPART | LIMIT 100 m/s")
	state_changed.emit()

func _physics_process(delta: float) -> void:
	if player.flight_paused or state == State.DOCKED:
		return
	_message_seconds = maxf(0.0, _message_seconds - delta)
	if state == State.AUTODOCK:
		_advance_autodock(delta)
		return
	if state == State.LAUNCHING:
		# End launch assistance once the entire hull clears the station interior,
		# even though the ship is still inside the inbound approach zone.
		var radius: float = (hull.shape as SphereShape3D).radius
		if not active_station.contains(active_station.interior_volume, player.global_position, -radius):
			active_station = null
			state = State.FLIGHT
			player.set_approach_speed_limit(0.0)
			_notice("CLEAR OF STATION | NORMAL FLIGHT")
			state_changed.emit()
		_previous_position = player.global_position
		return
	if cleared_station != null:
		_update_clearance()
	elif _message_seconds == 0.0:
		var nearby: DockingStation = nearest_station()
		message = "F: REQUEST DOCKING — " + nearby.display_name if nearby != null else "F: REQUEST DOCKING NEAR A STATION"
	_previous_position = player.global_position

func _update_clearance() -> void:
	var station: DockingStation = cleared_station
	if player.global_position.distance_to(station.entrance.global_position) > station.revoke_range:
		clearance_off("CLEARANCE REVOKED | OUT OF RANGE")
		return
	var assisted: bool = station.contains(station.approach_volume, player.global_position)
	player.set_approach_speed_limit(station.assisted_speed if assisted else 0.0)
	var radius: float = (hull.shape as SphereShape3D).radius
	if station.crossed_entrance(_previous_position, player.global_position, radius):
		_entered = true
	# Leaving the bounded interior invalidates the entrance history, including
	# flying out through the open roof of the service platform.
	if _entered and not station.contains(station.interior_volume, player.global_position):
		_entered = false
	if station.contains(station.capture_volume, player.global_position, radius):
		if not _entered:
			message = "EXIT AND RE-ENTER THROUGH THE MARKED ENTRANCE"
		elif not station.facing_inward(-player.global_basis.z) or player.velocity.dot(-station.entrance.global_basis.z) < -0.01:
			message = "ALIGN FORWARD WITH DOCKING BAY"
		elif player.current_speed > station.assisted_speed + 0.1:
			message = "SLOW TO 100 m/s FOR DOCKING"
		else:
			_begin_autodock(station)
	elif _message_seconds == 0.0:
		message = "CLEARED: %s | %s" % [station.display_name, "APPROACH LIMIT 100 m/s" if assisted else "FOLLOW ENTRANCE MARKER"]

func _path_clear(start: Vector3, finish: Vector3) -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = hull.shape
	query.transform = Transform3D(player.global_basis, start)
	query.motion = finish - start
	query.margin = 0.2
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]
	var space: PhysicsDirectSpaceState3D = player.get_world_3d().direct_space_state
	if not space.intersect_shape(query, 1).is_empty():
		return false
	var result: PackedFloat32Array = space.cast_motion(query)
	query.transform.origin = finish
	query.motion = Vector3.ZERO
	return result[0] >= 1.0 and space.intersect_shape(query, 1).is_empty()

func _begin_autodock(station: DockingStation) -> void:
	if not _path_clear(player.global_position, station.berth.global_position):
		message = "DOCKING PATH BLOCKED | RETAINING MANUAL CONTROL"
		return
	active_station = station
	state = State.AUTODOCK
	_autodock_start = player.global_transform
	_autodock_elapsed = 0.0
	player.set_external_control(true)
	message = "AUTODOCK | " + station.display_name
	state_changed.emit()

func _advance_autodock(delta: float) -> void:
	_autodock_elapsed += delta
	var progress: float = clampf(_autodock_elapsed / maxf(active_station.autodock_seconds, 0.1), 0.0, 1.0)
	var eased: float = smoothstep(0.0, 1.0, progress)
	var target: Transform3D = _autodock_start.interpolate_with(active_station.berth.global_transform, eased)
	if not _path_clear(player.global_position, target.origin):
		state = State.FLIGHT
		active_station = null
		player.set_external_control(false)
		clearance_off("AUTODOCK INTERRUPTED | PATH BLOCKED")
		return
	player.global_transform = target
	if progress >= 1.0:
		state = State.DOCKED
		message = "DOCKING COMPLETE"
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		state_changed.emit()

func _notice(text: String) -> void:
	message = text
	_message_seconds = 3.0
