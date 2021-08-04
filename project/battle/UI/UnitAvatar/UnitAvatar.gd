extends Control

onready var camera := $ViewportContainer/Viewport/Camera
onready var hp_bar := $HPBar
onready var move_points_bar := $MovePointsBar

const DEFAULT_BG_COLOR = Color("#222034")

var unit: BattleUnit

signal avatar_click(click_unit)


func initialize(max_hp: int, max_move_points: int):
	hp_bar.max_value = max_hp
	move_points_bar.value = max_move_points
	
func update_hp(hp: int):
	hp_bar.value = hp
	
func update_move_points(mp: int):
	move_points_bar.value = mp

func set_unit(battle_unit: BattleUnit):
	unit = battle_unit
	name = "UnitAvatar_%s" % unit.id

func _on_UserAvatar_pressed():
	emit_signal("avatar_click", unit)
	accept_event()
