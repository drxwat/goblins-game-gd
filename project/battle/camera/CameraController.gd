extends Camera
class_name CameraController

enum CAMERA_ACTIONS{
	MOVING,
	FOCUS,
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

export(float, 0.0, 30.0) var focus_duration = 0.8
export(float, 1.0, 100.0) var focus_speed = 30

onready var camera_input = $CameraInput

var pitch : float
var yaw : float
var current_action = CAMERA_ACTIONS.MOVING
var velocity : Vector2

var focus_target : Vector2
var focus_tween : Tween

func _ready():
	pitch = rotation.x
	yaw = rotation.y

func change_action(action):
	current_action = action
	match(current_action):
		CAMERA_ACTIONS.MOVING:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		CAMERA_ACTIONS.FOCUS:
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(delta):
	
	match(current_action):
		CAMERA_ACTIONS.MOVING:
			#CAMERA MOVEMENT
			velocity.x = clamp(velocity.x * movement_damping,-1.0,1.0)
			velocity.y = clamp(velocity.y * movement_damping,-1.0,1.0)
			
			if velocity != Vector2.ZERO:
				move(velocity)
		CAMERA_ACTIONS.FOCUS:
			if focus_tween != null:
				return

			focus_tween = Tween.new()
			add_child(focus_tween)
			var focus_target_3d = Vector3(focus_target.x, self.global_transform.origin.y, focus_target.y)
			var src_position = self.global_transform.origin
			var focus_duration = src_position.distance_to(focus_target_3d) / focus_speed
			focus_tween.interpolate_property(self, "global_transform:origin",
				src_position, focus_target_3d, focus_duration,
				Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			focus_tween.start()
			yield(focus_tween, "tween_completed")
			remove_child(focus_tween)
			focus_tween.queue_free()

			camera_input.change_action(CAMERA_ACTIONS.MOVING)
			change_action(CAMERA_ACTIONS.MOVING)
			focus_tween = null

func change_velocity(_velocity : Vector2):
	velocity = _velocity

func focus_to(position : Vector2):
	focus_target = position
	# works only for ∠ 45
	focus_target.y += self.transform.origin.y
	camera_input.change_action(CAMERA_ACTIONS.FOCUS)
	change_action(CAMERA_ACTIONS.FOCUS)
	
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

