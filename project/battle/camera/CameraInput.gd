extends Node

export(float,0.001,1.0) var screen_edge_size : float = 0.3
export(float) var mouse_wheel_damping = 0.9
export(float,0.0,1.0) var joy_dead_zone = 0.05


#USED TO CALCULATE RAW MOVEMENT WHILE PUSHING AN EDGE
var horizontal : float = 0.0
var vertical : float = 0.0

var is_keyboard_control : bool = true

#USED TO STORE MOUSE WHEEL INERTIA TO ENABLE SMOOTH STOPPING
var mouse_wheel : float  = 0.0

signal on_change_velocity(velocity)
signal on_change_action(new_state)

var current_action

#TOUCH VARIABLE FOR MOBILE
var touch_count : int = 0
var swipe_start : Vector2

#Gamepad
var right_stick_horizontal : float
var right_stick_vertical : float

func _ready():
	connect("on_change_action",self,"change_action")
	emit_signal("on_change_action",CameraController.CAMERA_ACTIONS.MOVING)

func change_action(action):
	current_action = action
	
func toggle_action():
	current_action = 1 - current_action

func start_swipe(position : Vector2):
	swipe_start = position

func move_swipe(position : Vector2):
	if blocked_movement:
		return
		
	var delta = (position - swipe_start)*-1
	var direction_x = sign(delta.x)
	var direction_y = sign(delta.y)
	
	var view_size = get_viewport().get_visible_rect().size - Vector2.ONE
	
	horizontal = range_lerp(abs(delta.x),0,view_size.x,0.0,1.0)
	vertical = range_lerp(abs(delta.y),0,view_size.y,0.0,1.0)
	
	#Applies direction
	horizontal *= direction_x
	vertical *= direction_y
	
var touches = [ Vector2.ZERO, Vector2.ZERO ]
var start_pinch_distance : float
var last_pinch_distance : float
var pinching : float

var blocked_movement : bool = false

func enable_movement():
	blocked_movement = false

func disable_movement():
	blocked_movement = true

func _input(event):
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		#MOBILE##############
		if event is InputEventScreenTouch:
			#SET TOUCH STARTING POSTIION
			touches[event.index] = event.position
			if event.pressed:
				touch_count += 1
				start_swipe(event.position)
			else:
				touch_count -= 1
				#RENABLE SWIPE MOVEMENT BECAUSE EVERY TOUCH WAS LIFTED
				if blocked_movement and touch_count <= 0:
					blocked_movement = false
			
			#RESET PINCHING VALUE WHEN A NEW TOUCH IS DETECTED OR HAS BEEN LIFTED
			pinching = 0.0
				
		if event is InputEventScreenDrag:
			if touch_count == 2:
				#UPDATE TOUCHES POSITIONS
				touches[event.index] = event.position
				#CALCULATE DISTANCE BETWEEN TOUCHES
				var pinch_distance = (touches[1] - touches[0]).length()
				var pinch_direction = 1 if pinch_distance > last_pinch_distance else -1
				#CALCULATE PINCH DELTA
				pinching = abs(start_pinch_distance - pinch_distance) * pinch_direction
				#USE MOUSE WHEEL BUFFER TO ENABLE SMOOTHING
				mouse_wheel += pinching * get_process_delta_time()
				last_pinch_distance = pinch_distance
			else:
				if current_action == CameraController.CAMERA_ACTIONS.MOVING:
					move_swipe(event.position)
					
		###############MOBILE
	else:
	#PC##################
	#Camera edge pushing
		if event is InputEventJoypadMotion:
			#Writing gamepad left axis values
			horizontal = event.axis_value if event.axis == 0 else horizontal
			vertical = event.axis_value if event.axis == 1 else vertical
			#Adjusting by deadzone
			horizontal = 0.0 if abs(horizontal) < joy_dead_zone else horizontal
			vertical = 0.0 if abs(vertical) < joy_dead_zone else vertical
			
			#Writting gamepad right axis values
			right_stick_horizontal = event.axis_value if event.axis == 2 else right_stick_horizontal
			right_stick_vertical = event.axis_value if event.axis == 3 else right_stick_vertical
			#Adjusting by deadzone
			right_stick_horizontal = 0.0 if abs(right_stick_horizontal) < joy_dead_zone else right_stick_horizontal
			right_stick_vertical = 0.0 if abs(right_stick_vertical) < joy_dead_zone else right_stick_vertical
#			print("Axis: %s -> %s" % [event.axis,event.axis_value])
	###################PC

func handle_keyboard():
	var vertical_keyboard = 0
	var horizontal_keyboard = 0
	var move_directions = {
		KEY_W: Vector2(0, -1),
		KEY_S: Vector2(0, 1),
		KEY_A: Vector2(-1, 0),
		KEY_D: Vector2(1, 0),
	}

	for key in move_directions:
		if Input.is_key_pressed(key):
			var dir = move_directions[key]
			horizontal_keyboard += dir.x
			vertical_keyboard += dir.y
			is_keyboard_control = true

	if is_keyboard_control:
		horizontal = horizontal_keyboard
		vertical = vertical_keyboard
		if Vector2(horizontal, vertical) == Vector2.ZERO:
			is_keyboard_control = false
				
func _process(delta):
	#PC######
	handle_keyboard()

	match(current_action):
		CameraController.CAMERA_ACTIONS.MOVING:
			#RESIDUAL MOVEMENT
			if (horizontal != 0 or vertical != 0) and not blocked_movement:
				emit_signal("on_change_velocity",Vector2(horizontal, vertical))
	#######PC
