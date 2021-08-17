extends Spatial

export(int, 1, 30) var Move_Margin = 20
export(float, 1.0, 30.0) var Move_Speed = 10.0
export(float, 10.0, 100.0) var Focus_Speed = 30.0
export(float, 1.0, 50.0) var Rotation_Speed: float = 7.0
export(float, 1.0, 5.0) var Zoom_In_Limit = 2.0
export(float, 5.0, 30.0) var Zoom_Out_Limit = 20.0
export(float, 0.1, 2.0) var Zoom_Duration = 0.7
export(float, 1.0, 10.0) var Zoom_Speed = 3.0

var g_delta: float


func _physics_process(delta: float):
	g_delta = delta
	calc_move(delta)


func calc_move(delta: float):
	var mouse_pos = get_viewport().get_mouse_position()
	var win_size = get_viewport().size
	var move_vec = Vector3()
	
	if mouse_pos.x < Move_Margin and $RayCastLeft.is_colliding():
		move_vec.x = -1
	if mouse_pos.y < Move_Margin and $RayCastFront.is_colliding():
		move_vec.z = -1
	if mouse_pos.x > win_size.x - Move_Margin and $RayCastRight.is_colliding():
		move_vec.x = 1
	if mouse_pos.y > win_size.y - Move_Margin and $RayCastBack.is_colliding():
		move_vec.z = 1
	
	translate(move_vec * delta * Move_Speed)


func _input(event: InputEvent):
	if Input.is_action_pressed("ToggleCameraAction") and event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		rotate_y(-event.relative.x * Rotation_Speed * 0.01 * g_delta)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		
	if event.is_action_pressed("ScrollUp")\
	or event.is_action_pressed("ScrollDown"):
		var stop_point = Vector3.ZERO
		if event.is_action_pressed("ScrollUp"):
			stop_point = $Camera.transform.origin - $Camera.transform.basis.z * Zoom_Speed
		if event.is_action_pressed("ScrollDown"):
			stop_point = $Camera.transform.origin + $Camera.transform.basis.z * Zoom_Speed
		stop_point.y = clamp(stop_point.y, Zoom_In_Limit, Zoom_Out_Limit)
		stop_point.z = clamp(stop_point.z, Zoom_In_Limit, Zoom_Out_Limit)
		$Tween.interpolate_property($Camera, "transform:origin",
			$Camera.transform.origin, stop_point, Zoom_Duration,
			Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.start()


func focus_to(target: Vector3):
	target.y = global_transform.origin.y
	var focus_duration = global_transform.origin.distance_to(target) / Focus_Speed
	$Tween.interpolate_property(self, "global_transform:origin",
		global_transform.origin, target, focus_duration,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
