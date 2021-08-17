extends Spatial

export(float, 1.0, 30.0) var move_speed = 8.0
export(float, 10.0, 100.0) var focus_speed = 30.0
export(float, 1.0, 50.0) var horz_rotation_speed: float = 7.0
export(float, 0.1, 5.0) var vert_rotation_speed = 2.5
export(float, 1.0, 5.0) var zoom_in_limit = 2.0
export(float, 5.0, 30.0) var zoom_out_limit = 20.0
export(float, 0.1, 2.0) var zoom_duration = 0.8
export(float, 1.0, 10.0) var zoom_speed = 2.5

var g_delta: float


func _physics_process(delta: float):
	g_delta = delta
	calc_move(delta)


func calc_move(delta: float):
	var move_vec = Vector3()
	var current_speed = move_speed
	
	if not Input.is_action_pressed("MiddleMouseButton"):
		if Input.is_action_pressed("Left") and $RayCastLeft.is_colliding():
			move_vec.x = -1
		if Input.is_action_pressed("Forward") and $RayCastFront.is_colliding():
			move_vec.z = -1
		if Input.is_action_pressed("Right") and $RayCastRight.is_colliding():
			move_vec.x = 1
		if Input.is_action_pressed("Backward") and $RayCastBack.is_colliding():
			move_vec.z = 1
	
	if Input.is_action_pressed("Shift"):
		current_speed = move_speed * 2
	translate(move_vec.normalized() * delta * current_speed)


func _input(event: InputEvent):
	if Input.is_action_pressed("MiddleMouseButton")\
	and event is InputEventMouseMotion\
	and not Input.is_action_pressed("Ctrl"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		rotate_y(-event.relative.x * horz_rotation_speed * 0.01 * g_delta)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if (event.is_action_pressed("ScrollUp")\
	or event.is_action_pressed("ScrollDown"))\
	and not Input.is_action_pressed("Ctrl"):
		var stop_point = Vector3.ZERO
		if event.is_action_pressed("ScrollUp"):
			stop_point = $Gizmo/Camera.transform.origin - $Gizmo/Camera.transform.basis.z * zoom_speed
		if event.is_action_pressed("ScrollDown"):
			stop_point = $Gizmo/Camera.transform.origin + $Gizmo/Camera.transform.basis.z * zoom_speed
		stop_point.y = clamp(stop_point.y, zoom_in_limit, zoom_out_limit)
		stop_point.z = clamp(stop_point.z, zoom_in_limit, zoom_out_limit)
		$Tween.interpolate_property($Gizmo/Camera, "transform:origin",
				$Gizmo/Camera.transform.origin, stop_point, zoom_duration,
				Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.start()

	$Gizmo.rotation_degrees.x = clamp($Gizmo.rotation_degrees.x, -40, +40)
	if Input.is_action_pressed("Ctrl"):
		if Input.is_action_pressed("ScrollUp"):
			$Gizmo.rotate_x(-vert_rotation_speed * g_delta)
		if Input.is_action_pressed("ScrollDown"):
			$Gizmo.rotate_x(vert_rotation_speed * g_delta)
#			$Tween.interpolate_property($Gizmo, "rotation:x", $Gizmo.rotation.x,
#					$Gizmo.rotation.x + vert_rotation_speed * g_delta,
#					g_delta * 100, Tween.TRANS_QUAD, Tween.EASE_OUT)
#			$Tween.start()


func focus_to(target: Vector3):
	target.y = global_transform.origin.y
	var focus_duration = global_transform.origin.distance_to(target) / focus_speed
	$Tween.interpolate_property(self, "global_transform:origin",
			global_transform.origin, target, focus_duration,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
