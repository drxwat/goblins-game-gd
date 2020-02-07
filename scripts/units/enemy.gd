extends "./unit.gd"

export (NodePath) var _aim_node_path

var _aim: Node2D
var _follow_aim: bool = false


func _on_ready():
	if _aim_node_path:
		_aim = get_node(_aim_node_path)
	._on_ready()


func _on_process(delta):
	if _aim and _follow_aim:
		set_target(_aim.global_position)
	._on_process(delta)


func _on_Area2D_body_entered(_body):
	_follow_aim = true
	set_process(true)
	pass # Replace with function body.


func _on_Area2D_body_exited(_body):
	_follow_aim = false
	set_process(false)
	pass # Replace with function body.
