extends Spatial

const GIZMO_ANGLE_MIN: float = -0.6
const GIZMO_ANGLE_MAX: float = +0.6

export(float, 1.0, 30.0) var move_speed = 8.0
export(float, 1.0, 5.0) var shift_coefficient = 2.5
export(float, 10.0, 100.0) var focus_speed = 30.0
export(float, 1.0, 50.0) var horz_rotation_speed: float = 7.0
export(float, 0.0, 20.0) var vert_rotation_speed = 8.0
export(float, 1.0, 5.0) var zoom_in_limit = 2.0
export(float, 5.0, 30.0) var zoom_out_limit = 20.0
export(float, 1.0, 10.0) var zoom_speed = 2.5
export(float, 0.1, 2.0) var zoom_inertia = 0.75

var vert_rotation_inertia: float = 0.6
var g_delta: float


func _physics_process(delta: float):
	g_delta = delta
	calc_move(delta)


func calc_move(delta: float):
	var move_vec = Vector3()
	var current_speed = move_speed

	if Input.is_action_pressed("left") and $RayCastLeft.is_colliding():
		move_vec.x = -1
	if Input.is_action_pressed("forward") and $RayCastFront.is_colliding():
		move_vec.z = -1
	if Input.is_action_pressed("right") and $RayCastRight.is_colliding():
		move_vec.x = 1
	if Input.is_action_pressed("backward") and $RayCastBack.is_colliding():
		move_vec.z = 1
	
	if Input.is_action_pressed("Shift"):
		current_speed = move_speed * shift_coefficient

	translate(move_vec.normalized() * delta * current_speed)


func _input(event: InputEvent):
	if Input.is_action_pressed("middle_mouse")\
	and event is InputEventMouseMotion:
		rotate_y(-event.relative.x * horz_rotation_speed * 0.01 * g_delta)
	
	if Input.is_action_pressed("middle_mouse")\
	and event is InputEventMouseMotion:
		$Gizmo.rotate_x(
			-event.relative.y * horz_rotation_speed * 0.01 * g_delta
		)

	if	(Input.is_action_pressed("left")
	or	Input.is_action_pressed("right")
	or	Input.is_action_pressed("forward")
	or	Input.is_action_pressed("backward")
	) and Input.is_action_pressed("middle_mouse")\
	or Input.is_action_pressed("middle_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if (event.is_action_pressed("scroll_up")\
	or event.is_action_pressed("scroll_down"))\
	and not Input.is_action_pressed("Ctrl"):
		var stop_point = Vector3.ZERO
		if event.is_action_pressed("scroll_up"):
			stop_point = $Gizmo/Camera.transform.origin - $Gizmo/Camera.transform.basis.z * zoom_speed
		if event.is_action_pressed("scroll_down"):
			stop_point = $Gizmo/Camera.transform.origin + $Gizmo/Camera.transform.basis.z * zoom_speed
		stop_point.y = clamp(stop_point.y, zoom_in_limit, zoom_out_limit)
		stop_point.z = clamp(stop_point.z, zoom_in_limit, zoom_out_limit)
		$Tween.interpolate_property($Gizmo/Camera, "transform:origin",
				$Gizmo/Camera.transform.origin, stop_point,
				zoom_inertia, Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Tween.start()

	if Input.is_action_pressed("Ctrl"):
		var stop_angle = $Gizmo.rotation.x
		if Input.is_action_pressed("scroll_up"):
			stop_angle -= vert_rotation_speed * g_delta
			_apply_rotation_tween(stop_angle)
		if Input.is_action_pressed("scroll_down"):
			stop_angle += vert_rotation_speed * g_delta
			_apply_rotation_tween(stop_angle)


func focus_to(target: Vector3):
	target.y = global_transform.origin.y
	var focus_duration = global_transform.origin.distance_to(target) / focus_speed
	$Tween.interpolate_property(self, "global_transform:origin",
			global_transform.origin, target, focus_duration,
			Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()


func _apply_rotation_tween(stop_angle: float):
	stop_angle = clamp(stop_angle, GIZMO_ANGLE_MIN, GIZMO_ANGLE_MAX)
	$Tween.interpolate_property($Gizmo, "rotation:x",
			$Gizmo.rotation.x, stop_angle,
			vert_rotation_inertia, Tween.TRANS_CIRC, Tween.EASE_OUT)
	$Tween.start()
