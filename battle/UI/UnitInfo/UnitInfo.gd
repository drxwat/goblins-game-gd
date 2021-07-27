extends VBoxContainer
tool

onready var hp := $VBoxContainer/MarginContainer2/HBoxContainer/HealthPoints
onready var move_points := $VBoxContainer/MarginContainer3/HBoxContainer2/MovePoints
onready var portrait := $VBoxContainer/MarginContainer/Control/Portrait

export var is_mirrored := false

func _ready():
	pass
#	portrait.flip_h = is_mirrored

func set_portrait(texture: Texture):
	pass
#	portrait.texture = texture

func update_hp(value, max_value):
	pass
#	hp.text = _format_point_value(value, max_value)
	
func update_move_points(value, max_value):
	pass
#	move_points.text = _format_point_value(value, max_value)

func _format_point_value(value: int, max_value: int) -> String:
	return "%s/%s" % [value, max_value]
	
