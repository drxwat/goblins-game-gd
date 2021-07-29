extends Control
tool 

var user_avatar_scene := preload("res://battle/UI/UserAvatart/UserAvatar.tscn")

#onready var unit_info := $MarginContainer/VBoxContainer/Units/UnitInfo
#onready var enemy_info := $MarginContainer/VBoxContainer/Units/EnemyInfo
onready var next_turn_btn := $MarginContainer/VBoxContainer/Actions/NextTurn
onready var units_container := $MarginContainer/VBoxContainer/Units

signal next_turn_pressed

func set_team_units(units: Array):
	for unit in units:
		var user_avatar = user_avatar_scene.instance()
		user_avatar.set_unit(unit)
		units_container.add_child(user_avatar)

func display_unit_info(unit: BattleUnit):
	pass
#	unit_info.update_hp(unit.hp, unit.max_hp)
#	unit_info.update_move_points(unit.move_points, unit.max_move_points)
#	unit_info.set_portrait(unit.get_portrait())
#	unit_info.visible = true

func display_enemy_info(unit: BattleUnit):
	pass
#	enemy_info.update_hp(unit.hp, unit.max_hp)
#	enemy_info.update_move_points(unit.move_points, unit.max_move_points)
#	enemy_info.set_portrait(unit.get_portrait())
#	enemy_info.visible = true

func hide_unit_info():
	pass
#	unit_info.visible = false

func hide_enemy_info():
	pass
#	enemy_info.visible = false

func on_next_turn_press():
	next_turn_btn.disabled = true
	emit_signal("next_turn_pressed")

func enable_next_turn_button():
	next_turn_btn.disabled = false
