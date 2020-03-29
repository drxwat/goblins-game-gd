extends KinematicBody

const SPEED  := 100

var _path: PoolVector3Array 


func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if not _path.empty():
		move_along_distance(delta * SPEED)


func move_along_distance(distance: float) -> void:
	var start_point := global_transform.origin
	for i in range(_path.size()):
		var move_vector: Vector3 = _path[0] - start_point
		if move_vector.length() < 0.1:
			_path.remove(0)
			continue
		move_and_slide(move_vector.normalized() * distance)
		


#func move_along_distance(distance: float) -> void:
#	var start_point := global_transform.origin
#	for i in range(_path.size()):
#		var distance_to_next := start_point.distance_to(_path[0])
#		if distance <= distance_to_next and distance >= 0.0:
#			var move_vec = start_point.linear_interpolate(_path[0], distance / distance_to_next)
#			move_and_slide(move_vec.normalized(), Vector3(0, 1, 0))
#			break
#		elif distance < 0.0:
#			move_and_slide(_path[0].normalized(), Vector3(0, 1, 0))
#			set_process(false)
#			break
#		distance -= distance_to_next
#		start_point = _path[0]
#		_path.remove(0)

func set_path(path: PoolVector3Array) -> void:
	_path = path
