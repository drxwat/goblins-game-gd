extends Control

onready var camera := $ViewportContainer/Viewport/Camera
var unit: BattleUnit

#func _ready():
#	set_unit($GoblinBattleUnit)

func _physics_process(delta):
	if unit:
		camera.global_transform = unit.get_camera_transform()

func set_unit(battle_unit: BattleUnit):
	unit = battle_unit

