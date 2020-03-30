extends KinematicBody

const SPEED  := 300

var _path: PoolVector3Array 


func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if not _path.empty():
		move_along_path(delta)


func move_along_path(delta) -> void:
	var move_vector: Vector3 = _path[0] - global_transform.origin
	if move_vector.length() < 0.1:
		_path.remove(0)
	else:
		move_and_slide(move_vector.normalized() * SPEED * delta, Vector3(0, 1, 0))


func set_path(path: PoolVector3Array) -> void:
	_path = path
