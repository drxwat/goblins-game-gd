extends Control

onready var camera := $ViewportContainer/Viewport/Camera
var unit: BattleUnit

signal avatar_click(click_unit)

func _ready():
	$ViewportContainer.connect("mouse_entered", self, "on_mouse_entered")
	$ViewportContainer.connect("mouse_exited", self, "on_mouse_exited")
	# set_unit($GoblinBattleUnit)

var mouse_over = false

func _input(event):
	if mouse_over and event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			emit_signal("avatar_click", unit)
			accept_event()

func on_mouse_entered():
	mouse_over = true

func on_mouse_exited():
	mouse_over = false

func _physics_process(delta):
	if unit:
		camera.global_transform = unit.get_camera_transform()

func set_unit(battle_unit: BattleUnit):
	unit = battle_unit

