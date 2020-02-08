extends "./unit.gd"

export (NodePath) var _aim_node_path
export (float) var guard_radius = 350
export (float) var guard_radius_hunt_multiplier = 1.5

var _aim: Node2D
var _follow_aim: bool = false

var _idle_shape: CircleShape2D
var _hunt_shape: CircleShape2D
var _collision_shape: CollisionShape2D


func _on_ready():
	_idle_shape = CircleShape2D.new()
	_idle_shape.radius = guard_radius
	
	_hunt_shape = CircleShape2D.new()
	_hunt_shape.radius = guard_radius * guard_radius_hunt_multiplier
	
	_collision_shape = get_node("Area2D/CollisionShape2D")
	_collision_shape.shape = _idle_shape
	
	if _aim_node_path:
		_aim = get_node(_aim_node_path)
	._on_ready()


func _on_process(delta):
	if _aim and _follow_aim:
		set_target(_aim.global_position)
	._on_process(delta)


func _on_Area2D_body_shape_entered(_body_id, _body, _body_shape, _area_shape):
	if _follow_aim:
		return
	
	_collision_shape.shape = _hunt_shape
	_follow_aim = true
	set_process(true)


func _on_Area2D_body_shape_exited(_body_id, _body, _body_shape, _area_shape):
	if not _follow_aim:
		return
	
	_collision_shape.shape = _idle_shape
	_follow_aim = false
	set_process(false)
