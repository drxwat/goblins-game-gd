extends "./unit.gd"

enum Behavior { IDLE, PATROL, FOLLOW, FLEE }

export (NodePath) var _aim_node_path
export (float) var guard_radius = 350
export (float) var guard_radius_hunt_multiplier = 1.3

var _behavior: int = Behavior.IDLE
var _in_guard_area = false

var _visible = false

var _aim: Node2D
var _sprite: Sprite
var _tween: Tween
var _guard_area: CollisionShape2D


func _on_ready():
	_guard_area = get_node("GuardArea/CollisionShape2D")
	_guard_area.shape.radius = guard_radius
	
	if _aim_node_path:
		_aim = get_node(_aim_node_path)
		
	_sprite = get_node("Sprite")
	_tween = get_node("Tween")
	apply_visibility()
	._on_ready()


func _on_process(delta):
	match _behavior:
		Behavior.FLEE:
			flee(_aim)
		Behavior.FOLLOW:
			follow(_aim)
		Behavior.IDLE:
			if is_moving():
				stop_moving()

	._on_process(delta)


func apply_visibility() -> void:
	if (_tween.is_active()):
		# warning-ignore:return_value_discarded
		_tween.stop_all()
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(
		_sprite, "modulate", 
		_sprite.modulate, # from
		Color(1, 1, 1, 1 if _visible else 0), # to
		0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
	# warning-ignore:return_value_discarded
	_tween.start()


func follow(aim: Node2D):
	set_target(aim.global_position)


func flee(aim: Node2D):
	var flee_direction = -global_position.direction_to(aim.global_position)
	set_target(global_position + flee_direction * guard_radius)


func _on_GuardArea_body_shape_entered(_body_id, _body, _body_shape, _area_shape):
	if _in_guard_area:
		return
	
	var contact_behavior = Behavior.FLEE
	_behavior = contact_behavior
	_guard_area.shape.radius *=  guard_radius_hunt_multiplier
	_in_guard_area = true


func _on_GuardArea_body_shape_exited(_body_id, _body, _body_shape, _area_shape):
	if not _in_guard_area:
		return

	var contact_behavior = Behavior.IDLE
	_behavior = contact_behavior
	_guard_area.shape.radius /=  guard_radius_hunt_multiplier
	_in_guard_area = false


func _on_VisibilityArea_body_entered(_body):
	_visible = true
	apply_visibility()


func _on_VisibilityArea_body_exited(_body):
	_visible = false
	apply_visibility()


func _get_path_line_color():
	return Color(1, 0, 0, 1)
