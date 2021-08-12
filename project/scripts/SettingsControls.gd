extends Node

var Actions:Array = InputMap.get_actions()
var ActionControls:Dictionary = {}

func get_input_data() -> Dictionary:
	var inputs = {}
	for action_name in Actions:
		var button_list_data:Dictionary = {}
		if not ActionControls.has(action_name):
			continue
		var button_list:Array = ActionControls[action_name]
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

func set_input_data(inputs:Dictionary):
	for action_name in Actions:
		ActionControls[action_name] = []
	var action_names:Array = inputs.keys()
	for action_name in action_names:
		var button_names = inputs[action_name].keys()
		for button_name in button_names:
			var button = inputs[action_name][button_name]
			var event:InputEvent = set_button_data(button)
			ActionControls[action_name].push_back(event)
	set_InputMap()
	set_actions_info()

func default_controls()->void:	#Reset to project settings controls
	InputMap.load_from_globals()
	set_actions_info()

func set_actions_info()->void:
	ActionControls.clear()
	for Action in Actions:
		var ActionList:Array = InputMap.get_action_list(Action) #associated controlls to the action
		ActionControls[Action] = ActionList
