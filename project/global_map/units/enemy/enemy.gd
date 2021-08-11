extends Unit
class_name Enemy

enum Behavior { IDLE, PATROL, FOLLOW, FLEE, GO_TO }

export (float) var guard_radius = 350
export (float) var guard_radius_hunt_multiplier = 1.3

var _behavior: int = Behavior.IDLE
var _in_guard_area = false

var _visible = false

var _aim: Node2D
var _sprite: Sprite
var _tween: Tween
var _guard_area: CollisionShape2D
var _point_of_interest: Vector2
var _patrol_points: PoolVector2Array
var _patrol_left_points: PoolVector2Array
var _patrol_point_before_interruption: Vector2

var is_post_battle_timeout = false
var post_battle_timeout = 2

func _on_ready():
	_guard_area = $GuardArea/CollisionShape2D
	_guard_area.shape.radius = guard_radius
		
	_sprite = $Sprite
	_tween = $Tween
	_apply_visibility()
	._on_ready()


func _on_process(delta):
	_apply_behavior()
	._on_process(delta)

func idle():
	_behavior = Behavior.IDLE

func flee(aim: Node2D) -> void:
	_aim = aim
	_behavior = Behavior.FLEE


func follow(aim: Node2D) -> void:
	_aim = aim
	_behavior = Behavior.FOLLOW


func go_to(point: Vector2) -> void:
	_point_of_interest = point
	_behavior = Behavior.GO_TO


func set_patrol_route(points: PoolVector2Array):
	_patrol_points = points
	_patrol_left_points = PoolVector2Array(_patrol_points)


func patrol() -> void:
	_behavior = Behavior.PATROL


func resume_patrol():
	go_to(_patrol_point_before_interruption)


func interrupt_flee() -> void:
	_aim = null
	_switch_to_default_behavior()


func interrupt_follow() -> void:
	_aim = null
	_switch_to_default_behavior()


func interrupt_go_to() -> void:
	if _patrol_points:
		patrol()
	else:
		_switch_to_default_behavior()


func interrupt_patrol() -> void:
	if not _patrol_left_points.empty():
		_patrol_point_before_interruption = _point_of_interest
	_switch_to_default_behavior()


func is_patrol_over() -> bool:
	return _patrol_left_points.empty()


func _apply_behavior() -> void:
	match _behavior:
		Behavior.FLEE:
			_flee_behavior()
		Behavior.FOLLOW:
			_follow_behavior()
		Behavior.GO_TO:
			_go_to_behavior()
		Behavior.PATROL:
			_patrol_behavior()
		Behavior.IDLE:
			if is_moving():
				stop_moving()


func _interrupt_behavior(behavior: int):
	match behavior:
		Behavior.FLEE:
			interrupt_flee()
		Behavior.FOLLOW:
			interrupt_follow()
		Behavior.GO_TO:
			interrupt_go_to()
		Behavior.PATROL:
			interrupt_patrol()
	_on_interrupt_behavior(behavior)


func _switch_to_default_behavior():
	idle()


func _follow_behavior() -> void:
	set_target(_aim.global_position)


func _flee_behavior() -> void:
	var flee_direction = -global_position.direction_to(_aim.global_position)
	set_target(global_position + flee_direction * guard_radius)


func _go_to_behavior() -> void:
	set_target(_point_of_interest)
	if _path.empty():
		_interrupt_behavior(Behavior.GO_TO)


func _patrol_behavior() -> void:
	if _patrol_left_points.empty():
#		_patrol_left_points = PoolVector2Array(_patrol_points)
		_interrupt_behavior(Behavior.PATROL)
		return
	var next_point = _patrol_left_points[0]
	_patrol_left_points.remove(0)
	go_to(next_point)


# Callback for child classes to handle behavior intrruption
func _on_interrupt_behavior(behavior) -> void:
	pass

# Somebody enters the Guard Area
func _handle_guard_area_violation(unit: Node2D):
	pass
#	follow(unit)


# Another unit left the guard area
func _handle_guard_area_free():
	pass


func _apply_visibility() -> void:
	return
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
	if _in_guard_area:
		return

	_interrupt_behavior(_behavior)
	_handle_guard_area_violation(_body.owner)
	_guard_area.shape.radius *=  guard_radius_hunt_multiplier
	_in_guard_area = true


func _on_GuardArea_body_shape_exited(_body_id, _body: Unit, _body_shape, _area_shape):
	if not _in_guard_area:
		return

	_interrupt_behavior(_behavior)
	_handle_guard_area_free()
	_guard_area.shape.radius /=  guard_radius_hunt_multiplier
	_in_guard_area = false


func _on_VisibilityArea_body_entered(_body):
	_visible = true
	_apply_visibility()


func _on_VisibilityArea_body_exited(_body):
	_visible = false
	_apply_visibility()


func _get_path_line_color():
	return Color(1, 0, 0, 1)
