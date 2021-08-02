extends Control
tool 

var user_avatar_scene := preload("res://battle/UI/UserAvatart/UserAvatar.tscn")
var units_avatarts = Dictionary()

onready var next_turn_btn := $MarginContainer/VBoxContainer/Actions/NextTurn
onready var units_container := $MarginContainer/VBoxContainer/Units

signal next_turn_pressed
signal focus_unit(unit)

func set_team_units(units: Array):
	for unit in units:
		var user_avatar = user_avatar_scene.instance()
		user_avatar.set_unit(unit)
		user_avatar.connect("avatar_click", self, "on_avatar_click")
		units_container.add_child(user_avatar)
		user_avatar.initialize(unit.max_hp, unit.max_move_points)
		units_avatarts[unit] = user_avatar

func on_avatar_click(unit: BattleUnit):
	emit_signal("focus_unit", unit)

func update_unit_info(unit: BattleUnit):
	var avatar = units_avatarts[unit]
	avatar.update_hp(unit.hp)
	avatar.update_move_points(unit.move_points)
	
func remove_unit_avatar(unit: BattleUnit):
	var avatar = units_avatarts[unit]
	units_container.remove_child(avatar)

func display_enemy_info(unit: BattleUnit):
	pass

func hide_enemy_info():
	pass
#	enemy_info.visible = false

func on_next_turn_press():
	next_turn_btn.disabled = true
	emit_signal("next_turn_pressed")

func enable_next_turn_button():
	next_turn_btn.disabled = false
