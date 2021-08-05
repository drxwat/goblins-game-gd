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
signal on_turn_end
signal on_counter_attack_end

const SPEED  := 300

const LOCOMOTION_ANIMATION = "parameters/Locomotion/blend_amount"
const ACTIONS_ANIMATION = "parameters/Actions/playback"
const MELE_ATTACK_ANIMATION_NAME = "slash"
const TAKE_DAMAGE_ANIMATION_NAME = "react"
const DIE_ANIMATION_NAME = "death"
const ANIMATION_TRANSITION = 0.4
const ROTATION_TRANSITION = 0.1

const BASE_HIT_CHANCE = 0.75
const HIT_CHACE_MULTIPLIER = 0.05
const MIN_HIT_CHANCE = 0.15
const MAX_HIT_CHANCE = 0.95
const MAX_COUNTER_ATTACKS = 4
const COUTER_ATTACK_MAX_MOVE_PENALTY_DEVIDER = 6

onready var animation_tree := $Gfx/AnimationTree
onready var tween = $Gfx/Tween

var rng = RandomNumberGenerator.new()

# STATS INITIAL
var max_hp: int 
var max_move_points: int

# STATS
var hp: int setget set_hp, get_hp
var move_points: int

var _path: PoolVector3Array
var _idle = true
var _is_selected := false setget set_selected
var global_unit : GlobalUnit setget set_global_unit # Unit Global Meta Info
var id: int setget , _get_unit_id
var firstname = "" setget , _get_firstname

var is_dead := false
var has_counter_attack : bool setget , get_has_counter_attack
var current_animation
var actions_state_machine
var couter_attacks_made := 0


export(GlobalConstants.WEAPON) var right_hand = GlobalConstants.WEAPON.NONE
export (GlobalConstants.WEAPON) var left_hand = GlobalConstants.WEAPON.NONE
export (GlobalConstants.BATTLE_TEAM) var team

func _ready():
	rng.randomize()
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

func _get_firstname():
	return global_unit.firstname

func next_turn_update(): # APPLY EFFECTS, REGENT, POISON etc
	move_points = max_move_points
	couter_attacks_made = 0

func set_path(path: PoolVector3Array) -> void:
	if move_points < path.size():
		path.resize(move_points)
	_path = path
	
func attack(unit: BattleUnit, with_counter_attack: bool):
	unit.take_damage(self, calculate_damage(unit), with_counter_attack)

func mele_attack(unit: BattleUnit):
	_rotate_unit(global_transform.origin.direction_to(unit.global_transform.origin))
	var actions_amount = floor(move_points / (max_move_points / GlobalConstants.MOVE_AREAS))
	for i in range(clamp(actions_amount + 1, 1, GlobalConstants.MOVE_AREAS)):	
		var with_counter_attack = unit.has_counter_attack
		_play_action_animation(MELE_ATTACK_ANIMATION_NAME)
		yield(self, "on_attack_end")
		attack(unit, unit.has_counter_attack)
		yield(unit, "on_take_damage_end")
		if unit.is_dead:
			break
		if with_counter_attack:
			yield(unit, "on_counter_attack_end")
			if is_dead:
				break
	move_points = 0
	emit_signal("on_turn_end")

func counter_attack(unit: BattleUnit):
	couter_attacks_made += 1
	_play_action_animation(MELE_ATTACK_ANIMATION_NAME)
	yield(self, "on_attack_end")
	attack(unit, false)
	yield(unit, "on_take_damage_end")
	var move_point_penalty = max_move_points / COUTER_ATTACK_MAX_MOVE_PENALTY_DEVIDER
	move_points -= move_point_penalty
	emit_signal("on_counter_attack_end")
	
	# MAKE MOVE_P penalty

func get_has_counter_attack():
	return couter_attacks_made < MAX_COUNTER_ATTACKS
	
func range_attack(unit: BattleUnit):
	pass

func take_damage(from: BattleUnit, damage: int, with_counter_attack = true):
	_rotate_unit(global_transform.origin.direction_to(from.global_transform.origin))
	self.hp -= damage
	if self.hp <= 0:
		call_deferred("die")
		return
	_play_action_animation(TAKE_DAMAGE_ANIMATION_NAME)
	if with_counter_attack:
		yield(self, "on_take_damage_end")
		counter_attack(from)

func die():
	is_dead = true
	emit_signal("on_take_damage_end")
	_play_animation(DIE_ANIMATION_NAME)
	emit_signal("on_dead")
	

func is_hits_target(victim: BattleUnit) -> bool:
	var attach_def_diff = global_unit.get_attack() - victim.global_unit.get_defence()
	var raw_hit_cance = BASE_HIT_CHANCE + (attach_def_diff * HIT_CHACE_MULTIPLIER)
	var hit_chance = clamp(raw_hit_cance, MIN_HIT_CHANCE, MAX_HIT_CHANCE)
	return rng.randf() < hit_chance

func calculate_damage(victim: BattleUnit):
	return 2

func set_selected(value: bool):
	_is_selected = value
	if _is_selected:
		$Selection.show()
	else:
		$Selection.hide()

### STATS API ###

func set_global_unit(_global_unit: GlobalUnit):
	global_unit = _global_unit
	max_hp = global_unit.get_max_hp()
	hp = global_unit.get_hp()
	max_move_points = global_unit.get_max_move_points()
	move_points = max_move_points


func get_hp():
	return global_unit.get_hp()
	
func set_hp(value: int):
	global_unit.set_hp(value)

### STATS API END ###

func _play_animation(animation_name):
	actions_state_machine.start(animation_name)

# state machine animation that requires polling to emit endsignal
func _play_action_animation(animation_name):
	current_animation = animation_name
	_play_animation(animation_name)
	$AnimationPoller.start()

func _check_animation_end():
	if actions_state_machine.get_current_node() != current_animation:
		if current_animation == MELE_ATTACK_ANIMATION_NAME:
			current_animation = null
			emit_signal("on_attack_end")
		elif current_animation == TAKE_DAMAGE_ANIMATION_NAME:
			current_animation = null
			emit_signal("on_take_damage_end")
	else:
		$AnimationPoller.start()

func _move_along_path(delta) -> void:
	var move_vector: Vector3 = _path[0] - global_transform.origin
	if move_vector.length() < 0.1:
		move_points -= 1
		emit_signal("on_move_step")
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
	
func _get_unit_id():
	return global_unit.id
	
