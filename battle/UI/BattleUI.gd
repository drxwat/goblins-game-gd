extends Control

onready var unit_info := $MarginContainer/VBoxContainer/Units/UnitInfo
onready var enemy_info := $MarginContainer/VBoxContainer/Units/EnemyInfo
onready var next_turn_btn := $MarginContainer/VBoxContainer/Actions/NextTurn

signal next_turn_pressed

func display_unit_info(unit: BattleUnit):
	unit_info.update_hp(unit.hp, unit.max_hp)
	unit_info.update_move_points(unit.move_points, unit.max_move_points)
	unit_info.set_portrait(unit.get_portrait())
	unit_info.visible = true

func display_enemy_info(unit: BattleUnit):
	enemy_info.update_hp(unit.hp, unit.max_hp)
	enemy_info.update_move_points(unit.move_points, unit.max_move_points)
	enemy_info.set_portrait(unit.get_portrait())
	enemy_info.visible = true

func hide_unit_info():
	unit_info.visible = false

func hide_enemy_info():
	enemy_info.visible = false

func on_next_turn_press():
	emit_signal("next_turn_pressed")
	next_turn_btn.disabled = true

func enable_next_turn_button():
	next_turn_btn.disabled = false
