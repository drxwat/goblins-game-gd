extends KinematicBody
class_name BattleUnit

#
# This is basic battle unit class that assumes that there is GFX child node
# in the child class that has AnimationTree, Tween and AnimationPlayer nodes
# in the root. Child class cutomizes graphix but that graphix must follow the
# restrictions. AnimationPlayer must contain basic anumations (see GoblinBattleUnit)
# More over it must have bones for right and left hands. 
#

signal on_move_end
signal on_move_step
signal on_attack_end
signal on_take_damage_end
signal on_dead

const SPEED  := 300

const LOCOMOTION_ANIMATION = "parameters/Locomotion/blend_amount"
const ACTIONS_ANIMATION = "parameters/Actions/playback"
const MELE_ATTACK_ANIMATION_NAME = "slash"
const TAKE_DAMAGE_ANIMATION_NAME = "react"
const DIE_ANIMATION_NAME = "death"
const ANIMATION_TRANSITION = 0.4
const ROTATION_TRANSITION = 0.1

onready var animation_tree := $Gfx/AnimationTree
onready var tween = $Gfx/Tween


# STATS INITIAL
var max_hp := 20
var max_move_points := 9

# STATS
var hp := max_hp
var move_points := max_move_points

var _path: PoolVector3Array
var _idle = true
var _is_selected := false setget set_selected
var battle_id: int # available only after battle spawn

var is_dead := false
var current_animation
var actions_state_machine


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
	actions_state_machine = animation_tree[ACTIONS_ANIMATION]
	_play_animation("idle-loop")

func _physics_process(delta):
	if is_dead:
		return
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

func next_turn_update(): # APPLY EFFECTS, REGENT, POISON etc
	move_points = max_move_points

func set_path(path: PoolVector3Array) -> void:
	_path = path
	
func attack(unit: BattleUnit):
	unit.take_damage(calculate_damage(self, unit))

func mele_attack(unit: BattleUnit):
	_play_action_animation(MELE_ATTACK_ANIMATION_NAME)
	yield(get_tree().create_timer(0.6), "timeout") # TODO: Configure delays for all attack animations 
	attack(unit)

func range_attack(unit: BattleUnit):
	pass

func take_damage(damage: int):
	hp -= damage
	if hp <= 0:
		die()
		return
	_play_action_animation(TAKE_DAMAGE_ANIMATION_NAME)

func die():
	_play_animation(DIE_ANIMATION_NAME)
	emit_signal("on_dead")
	is_dead = true

func calculate_damage(attacker: BattleUnit, victim: BattleUnit):
	return 21

func set_selected(value: bool):
	_is_selected = value
	if _is_selected:
		$Selection.show()
	else:
		$Selection.hide()

func _play_animation(animation_name):
	actions_state_machine.start(animation_name)

# state machine animation that requires polling to emit endsignal
func _play_action_animation(animation_name):
	current_animation = animation_name
	$AnimationPoller.start()
	_play_animation(animation_name)

func _check_animation_end():
	if actions_state_machine.get_current_node() != current_animation:
		if current_animation == MELE_ATTACK_ANIMATION_NAME:
			emit_signal("on_attack_end")
		elif current_animation == TAKE_DAMAGE_ANIMATION_NAME:
			emit_signal("on_take_damage_end")
		current_animation = null
	else:
		$AnimationPoller.start()

func _move_along_path(delta) -> void:
	var move_vector: Vector3 = _path[0] - global_transform.origin
	if move_vector.length() < 0.1:
		_path.remove(0)
	else:	
		_rotate_unit(move_vector)
		move_and_slide(move_vector.normalized() * SPEED * delta, Vector3(0, 1, 0))


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
	
