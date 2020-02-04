extends Node2D

const SPEED  := 800.0

var _path := PoolVector2Array()
var _path_weights := PoolRealArray()

func _ready():
	set_process(false)


func _process(delta):
	move_along_path(delta)


func move_along_path(delta: float) -> void:
	var start_point := position
	var remaining_time = delta
	for i in range(_path.size()):
		var distance_to_next := start_point.distance_to(_path[0])
		var current_speed = SPEED / _path_weights[0]
		var current_distance = current_speed * remaining_time
		if current_distance <= distance_to_next and current_distance >= 0.0:
			position = start_point.linear_interpolate(
					_path[0], 
					current_distance / distance_to_next
					)
			break
		elif current_distance < 0.0:
			position = _path[0]
			set_process(false)
			break
		remaining_time -= distance_to_next / current_speed
		start_point = _path[0]
		_path.remove(0)
		_path_weights.remove(0)


func set_path(path: PoolVector2Array, weights: PoolRealArray) -> void:
	_path = path
	_path_weights = weights
	if _path.size() == 0:
		return
	set_process(true)


#func move_along_distance(distance: float) -> void:
#	var start_point := position
#	for i in range(_path.size()):
#		var distance_to_next := start_point.distance_to(_path[0])
#		if distance <= distance_to_next and distance >= 0.0:
#			position = start_point.linear_interpolate(_path[0], distance / distance_to_next)
#			break
#		elif distance < 0.0:
#			position = _path[0]
#			set_process(false)
#			break
#		distance -= distance_to_next
#		start_point = _path[0]
#		_path.remove(0)
