extends Spatial


export var Move_Margin = 20
export var Move_Speed = 10
export var Rotation_Speed: float = 7.0
export var Zoom_In_Limit = 2
export var Zoom_Out_Limit = 20

var m_pos = Vector2.ZERO
var g_delta: float


func _ready():
	Move_Margin = clamp(Move_Margin, 1, 100)
	Move_Speed = clamp(Move_Speed, 1, 30)
	Rotation_Speed = clamp(Rotation_Speed, 1, 50)
	Zoom_In_Limit = clamp(Zoom_In_Limit, 1, 5.0)
	Zoom_Out_Limit = clamp(Zoom_Out_Limit, 5.0, 30.0)


func _physics_process(delta):
	g_delta = delta
	m_pos = get_viewport().get_mouse_position()
	calc_move(m_pos, delta)


func calc_move(m_pos, delta):
	var win_size = get_viewport().size
	var move_vec = Vector3()
	
	if m_pos.x < Move_Margin and $RayCastLeft.is_colliding():
		move_vec.x = -1
	if m_pos.y < Move_Margin and $RayCastFront.is_colliding():
		move_vec.z = -1
	if m_pos.x > win_size.x - Move_Margin and $RayCastRight.is_colliding():
		move_vec.x = 1
	if m_pos.y > win_size.y - Move_Margin and $RayCastBack.is_colliding():
		move_vec.z = 1
	
	translate(move_vec * delta * Move_Speed)


func _input(event):
	if Input.is_action_pressed("ToggleCameraAction") and event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		rotate_y(-event.relative.x * Rotation_Speed * 0.01 * g_delta)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	if event.is_action_pressed("ScrollUp"):
		$Camera.transform.origin -= $Camera.transform.basis.z;
	if event.is_action_pressed("ScrollDown"):
		$Camera.transform.origin += $Camera.transform.basis.z;
	$Camera.transform.origin.y = clamp($Camera.transform.origin.y, Zoom_In_Limit, Zoom_Out_Limit)
	$Camera.transform.origin.z = clamp($Camera.transform.origin.z, Zoom_In_Limit, Zoom_Out_Limit)
