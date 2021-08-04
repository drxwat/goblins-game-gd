extends Control

onready var camera := $ViewportContainer/Viewport/Camera
onready var hp_bar := $HPBar
onready var move_points_bar := $MovePointsBar
onready var label_unit_id := $id

const DEFAULT_BG_COLOR = Color("#222034")

var unit: BattleUnit setget set_unit

signal avatar_click(click_unit)

func update_hp(hp: int):
	hp_bar.value = hp
	
func update_move_points(mp: int):
	move_points_bar.value = mp

func set_unit(battle_unit: BattleUnit):
	unit = battle_unit
	hp_bar.max_value = unit.max_hp
	move_points_bar.value = unit.max_move_points
	label_unit_id.text = str(unit.id)
	name = "UnitAvatar_%s" % unit.id

func _on_UserAvatar_pressed():
	emit_signal("avatar_click", unit)
	accept_event()
