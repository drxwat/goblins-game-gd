extends Camera
class_name CameraController

enum CAMERA_ACTIONS{
	MOVING,
	ROTATING_VIEW,
}

export(float,1,100) var movement_speed = 30
export(float,0.01,0.99) var movement_damping = 0.74

#Value in percentage of screen portion
#A value of 0.3 means that when you place the cursor 30% or less away from an edge it will start pushing the camera
export(float, 0.0,1.0) var edge_size = 0.0

#EDIT HERE--->**,***<--- ZOOM MIN AND MAX LIMITS
export(float, 10,100) var min_zoom = 10
export(float, 10,100) var max_zoom = 100

export(float, 1,3) var zoom_sensibility = 2.5

export(float, 1,3) var rotation_sensibility = 2.3

var pitch : float
var yaw : float
var current_action = CAMERA_ACTIONS.MOVING
var velocity : Vector2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	
	pitch = rotation.x
	yaw = rotation.y

func change_action(action):
	current_action = action
	match(current_action):
		CAMERA_ACTIONS.MOVING:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		CAMERA_ACTIONS.ROTATING_VIEW:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	
	match(current_action):
		CAMERA_ACTIONS.MOVING:
			#CAMERA MOVEMENT
			velocity.x = clamp(velocity.x * movement_damping,-1.0,1.0)
			velocity.y = clamp(velocity.y * movement_damping,-1.0,1.0)
			
			if velocity != Vector2.ZERO:
				move(velocity)

func change_velocity(_velocity : Vector2):
	velocity = _velocity
	
func move(_velocity : Vector2):
	#Move along cameras X axis
	global_transform.origin += global_transform.basis.x * velocity.x * movement_speed * get_process_delta_time()
	#Calculate a forward camera direction that is perpendicular to the XZ plane
	var forward = global_transform.basis.x.cross(Vector3.UP)
	#Move the camera along that forward direction
	global_transform.origin += forward * velocity.y * movement_speed * get_process_delta_time()


func zoom(direction : float):
	#Zooming using fov
	var new_fov = fov + (sign(direction) * pow(abs(direction),zoom_sensibility)/100 * get_process_delta_time())
	fov = clamp(new_fov,min_zoom,max_zoom)


func rotate_view(axis : Vector2):
	
	var pitch_rotation_amount = -axis.y/100 * get_process_delta_time() * rotation_sensibility
	var yaw_rotation_amount = -axis.x/100 * get_process_delta_time() * rotation_sensibility
	
	pitch += pitch_rotation_amount
	pitch = clamp(pitch,-PI/2,0)
	
	yaw += yaw_rotation_amount
	
	rotation.x = pitch
	rotation.y = yaw
