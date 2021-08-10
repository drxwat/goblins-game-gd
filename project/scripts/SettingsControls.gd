extends Node

var Actions:Array = ["Right", "Left", "Up", "Down", "Jump"]
var ActionControls:Dictionary = {}

func get_input_data() -> Dictionary:
	var inputs = {}
	for action_name in SettingsControls.Actions:
		print("action_name = ", action_name)
	return inputs

func _ready():
	pass # Replace with function body.


