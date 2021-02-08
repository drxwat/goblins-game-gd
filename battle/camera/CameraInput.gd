extends Node

export(float,0.001,1.0) var screen_edge_size : float = 0.3
export(float) var mouse_wheel_damping = 0.9
export(float,0.0,1.0) var joy_dead_zone = 0.05


#USED TO CALCULATE RAW MOVEMENT WHILE PUSHING AN EDGE
var horizontal : float = 0.0
var vertical : float = 0.0

#USED TO STORE MOUSE WHEEL INERTIA TO ENABLE SMOOTH STOPPING
var mouse_wheel : float  = 0.0

signal on_change_velocity(velocity)
signal on_rotate_view(relative)
signal on_change_action(new_state)
signal on_zoom(value)

var current_action

#TOUCH VARIABLE FOR MOBILE
var touch_count : int = 0
var swipe_start : Vector2

#Gamepad
var right_stick_horizontal : float
var right_stick_vertical : float
#Used for enabling and disabling zoom
var right_stick_needs_reset : bool

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
var can_zoom : bool = true

func enable_zoom():
	can_zoom = true
	
func disable_zoom():
	can_zoom = false

func enable_movement():
	blocked_movement = false

func disable_movement():
	blocked_movement = true
	
func ask_right_stick_reset():
	right_stick_needs_reset = true

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
			if touch_count == 2:
				#STARTED ZOOMING, BLOCK MOVEMENT UNTIL EVERY TOUCH IS LIFTED
				blocked_movement = true
				start_pinch_distance = (touches[1] - touches[0]).length()
				
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
				elif current_action == CameraController.CAMERA_ACTIONS.ROTATING_VIEW:
					emit_signal("on_rotate_view",event.relative)
					
		###############MOBILE
	else:
	#PC##################
	#Camera edge pushing
		if event is InputEventMouseMotion:
			#ROTATE VIEW
			if current_action == CameraController.CAMERA_ACTIONS.ROTATING_VIEW:
				emit_signal("on_rotate_view",event.relative)
			#Gets screen size
			var view_size = get_viewport().get_visible_rect().size - Vector2.ONE
			#Get mouse position in percentage values relative to the screen
			var delta = (event.position) / view_size
			#Convert it to a range between [-1,1]
			delta = (delta * 2) - Vector2.ONE
			
			if current_action == CameraController.CAMERA_ACTIONS.MOVING:
				#Store it an buffer to use it on _process
				#Calculates delta based on percentage between the edge size and the actual edge
				horizontal = max(abs(delta.x) - (1.0 - screen_edge_size),0)
				vertical = max(abs(delta.y) - (1.0 - screen_edge_size),0)
				#Converts it to an [0.0,1.0] range
				horizontal = range_lerp(horizontal,0.0,screen_edge_size,0.0,1.0)
				vertical = range_lerp(vertical,0.0,screen_edge_size,0.0,1.0)
				#Applies direction
				horizontal *= sign(delta.x)
				vertical *= sign(delta.y)
			elif current_action == CameraController.CAMERA_ACTIONS.ROTATING_VIEW:
				horizontal = delta.x
				vertical = delta.y
				pass
		if event is InputEventMouseButton:
			#WHEEL SCROLL
			if can_zoom:
				if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:
					if event.pressed and not event.is_echo():
						var direction = (-1 if event.button_index == BUTTON_WHEEL_UP else 0) + (1 if event.button_index == BUTTON_WHEEL_DOWN else 0)
						mouse_wheel += direction * get_process_delta_time() * 1000
		
		
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
			if right_stick_vertical == 0.0:
				right_stick_needs_reset = false
#			print("Axis: %s -> %s" % [event.axis,event.axis_value])
	###################PC
				
func _process(delta):
	#PC######
	if Input.is_action_just_pressed("ToggleCameraAction"):
		emit_signal("on_change_action",CameraController.CAMERA_ACTIONS.ROTATING_VIEW)
	elif Input.is_action_just_released("ToggleCameraAction"):
		emit_signal("on_change_action",CameraController.CAMERA_ACTIONS.MOVING)
	
	
	match(current_action):
		CameraController.CAMERA_ACTIONS.MOVING:
			#RESIDUAL MOVEMENT
			if (horizontal != 0 or vertical != 0) and not blocked_movement:
				emit_signal("on_change_velocity",Vector2(horizontal, vertical))
			if right_stick_vertical != 0 and can_zoom and not right_stick_needs_reset:
				emit_signal("on_zoom",right_stick_vertical*50)
		CameraController.CAMERA_ACTIONS.ROTATING_VIEW:
			if right_stick_horizontal != 0 or right_stick_vertical != 0:
				emit_signal("on_rotate_view",100*Vector2(right_stick_horizontal, right_stick_vertical))
	#MOUSE WHEEL
	if mouse_wheel != 0:
		mouse_wheel = mouse_wheel * mouse_wheel_damping
		emit_signal("on_zoom",mouse_wheel)
	#######PC
