extends KinematicBody
class_name BattleUnit

const SPEED  := 300
const LOCOMOTION_ANIMATION = "parameters/Locomotion/blend_amount"
const ANIMATION_TRANSITION = 0.4
const ROTATION_TRANSITION = 0.1

var _path: PoolVector3Array
var _idle = true

onready var animation_tree := $Gfx/AnimationTree
onready var tween = $Gfx/Tween

func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if not _path.empty():
		# Start Blended Animation
		if _idle:
			_play_acceleration_animation()
			_idle = false
		move_along_path(delta)
	if _path.empty() and not _idle:
		_play_slowdown_animation()
		_idle = true


func move_along_path(delta) -> void:
	var move_vector: Vector3 = _path[0] - global_transform.origin
	if move_vector.length() < 0.1:
		_path.remove(0)
	else:	
		_rotate_unit(move_vector)
		move_and_slide(move_vector.normalized() * SPEED * delta, Vector3(0, 1, 0))


func set_path(path: PoolVector3Array) -> void:
	_path = path


func _play_acceleration_animation():
	tween.interpolate_property(animation_tree, LOCOMOTION_ANIMATION, 
		0, 1, ANIMATION_TRANSITION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
func _play_slowdown_animation():
	tween.interpolate_property(animation_tree, LOCOMOTION_ANIMATION, 
		1, 0, ANIMATION_TRANSITION / 2.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func _rotate_unit(move_direction):
	var angle = atan2(move_direction.x, move_direction.z)
	var new_rotation = get_rotation()
	new_rotation.y = angle
	tween.interpolate_property($".", "rotation",
		get_rotation(), new_rotation, ROTATION_TRANSITION, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
#	set_rotation(new_rotation)
