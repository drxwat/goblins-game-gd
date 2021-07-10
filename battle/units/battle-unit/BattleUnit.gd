extends KinematicBody
class_name BattleUnit

signal on_move_end

const SPEED  := 300
const LOCOMOTION_ANIMATION = "parameters/Locomotion/blend_amount"
const ANIMATION_TRANSITION = 0.4
const ROTATION_TRANSITION = 0.1

var _path: PoolVector3Array
var _idle = true
var _is_selected := false setget set_selected
var battle_id: int # available only after battle spawn

onready var animation_tree := $Gfx/AnimationTree
onready var tween = $Gfx/Tween

export(GlobalConstants.WEAPON) var right_hand = GlobalConstants.WEAPON.NONE
export (GlobalConstants.WEAPON) var left_hand = GlobalConstants.WEAPON.NONE
export (GlobalConstants.BATTLE_TEAM) var team

func _ready():
	var weapon_meta = _get_weapon_meta()
	if right_hand != GlobalConstants.WEAPON.NONE and weapon_meta.has(right_hand):
		var w_meta = weapon_meta.get(right_hand)
		var w_mesh = w_meta.mesh_scene.instance()
		w_mesh.scale = w_meta.scale
		w_mesh.translation = w_meta.translation
		w_mesh.rotation_degrees = w_meta.rotation_degrees
		$Gfx/Armature/Skeleton/RightHandAttachment.add_child(w_mesh)


func _physics_process(delta):
	if not _path.empty():
		# Start Blended Animation
		if _idle:
			_play_acceleration_animation()
			_idle = false
		_move_along_path(delta)
	if _path.empty() and not _idle:
		_play_slowdown_animation()
		_idle = true
		emit_signal("on_move_end")


func set_path(path: PoolVector3Array) -> void:
	_path = path
	

func _move_along_path(delta) -> void:
	var move_vector: Vector3 = _path[0] - global_transform.origin
	if move_vector.length() < 0.1:
		_path.remove(0)
	else:	
		_rotate_unit(move_vector)
		move_and_slide(move_vector.normalized() * SPEED * delta, Vector3(0, 1, 0))

func set_selected(value: bool):
	_is_selected = value
	if _is_selected:
		$Selection.show()
	else:
		$Selection.hide()

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

# Overwrite in child class with correct transforms for particular race
func _get_weapon_meta():
	return {}
	
