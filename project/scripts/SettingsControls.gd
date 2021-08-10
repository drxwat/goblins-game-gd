extends Node

var actions:Array = InputMap.get_actions()
var action_controls:Dictionary = {}

func get_input_data() -> Dictionary:
	var inputs = {}
	for action_name in actions:
		var button_list_data:Dictionary = {}
		if not action_controls.has(action_name):
			continue
		var button_list:Array = action_controls[action_name]
		var index:int = 0
		for button in button_list:
			button_list_data[index] = get_button_data(button)
			index += 1
		inputs[action_name] = button_list_data
	return inputs

func get_button_data(event)->Dictionary:
	var button_data:Dictionary = {}
	if event is InputEventKey:
		button_data["EventType"] = "InputEventKey"
		button_data["scancode"] = event.scancode
	if event is InputEventJoypadButton:
		button_data["EventType"] = "InputEventJoypadButton"
		button_data["device"] = event.device
		button_data["button_index"] = event.button_index
	if event is InputEventJoypadMotion:
		button_data["EventType"] = "InputEventJoypadMotion"
		button_data["device"] = event.device
		button_data["axis"] = event.axis
		button_data["axis_value"] = event.axis_value
	return button_data

