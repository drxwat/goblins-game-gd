extends Sprite3D

onready var _viewport = $"Viewport"
onready var _control = $"Viewport/ProgressBar"

var value = 0 setget set_value
var max_value = 100 setget set_max_value

func _ready():
	texture = _viewport.get_texture()


func set_max_value(value):
	if is_instance_valid(_viewport):
		_control.max_value = value
		_viewport.render_target_update_mode = Viewport.UPDATE_ONCE


func set_value(value):
	if is_instance_valid(_viewport):
		_control.value = int(clamp(value, 0, _control.max_value))
		_viewport.render_target_update_mode = Viewport.UPDATE_ONCE
		if value <= 0:
			visible = false
