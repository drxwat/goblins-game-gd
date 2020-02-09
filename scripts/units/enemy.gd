extends "./unit.gd"

export (NodePath) var _aim_node_path
export (float) var guard_radius = 350
export (float) var guard_radius_hunt_multiplier = 1.3

var _aim: Node2D
var _follow_aim: bool = false
var _guard_area: CollisionShape2D
var _visible = false
var _sprite: Sprite
var _tween: Tween

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
#	if _visible and _sprite.
	# Iterpolate modulate with Tween
	if _aim and _follow_aim:
		set_target(_aim.global_position)
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


func _on_GuardArea_body_shape_entered(_body_id, _body, _body_shape, _area_shape):
	if _follow_aim:
		return

	_guard_area.shape.radius *=  guard_radius_hunt_multiplier
	_follow_aim = true


func _on_GuardArea_body_shape_exited(_body_id, _body, _body_shape, _area_shape):
	if not _follow_aim:
		return

	_guard_area.shape.radius /=  guard_radius_hunt_multiplier
	_follow_aim = false
	stop_moving()


func _on_VisibilityArea_body_entered(_body):
	_visible = true
	apply_visibility()


func _on_VisibilityArea_body_exited(_body):
	_visible = false
	apply_visibility()

