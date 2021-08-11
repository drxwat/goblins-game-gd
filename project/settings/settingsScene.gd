extends Control

onready var ActionList = find_node("ActionList")
var ActionItem:PackedScene = preload("res://settings/ActionItem.tscn")
var ActionControl:PackedScene = preload("res://settings/ActionControl.tscn")
var ActionNodes:Dictionary = {} #To know which node to add ControlBinds

# Called when the node enters the scene tree for the first time.
func _ready():
	load_action_list()
	
func load_action_list():
	ActionNodes.clear()
	var list:Array = SettingsControls.Actions
	for action in list:
		print("action=", action)
		var action_node:VBoxContainer = ActionItem.instance()
		ActionList.add_child(action_node)
		ActionNodes[action] = action_node
		
		var ActionText:Label = action_node.find_node("ActionText") #Name of actions
		var Add:Button = action_node.find_node("AddAction") #Used for adding new ControlBind
		ActionText.text = action
		Add.connect("pressed", self, "add_control", [action])
		
		var list_controls:Array = SettingsControls.ActionControls[action] 
		for control in list_controls:
			show_control_event(action, control)
		#set_control_list(Action)

func show_control_event(action, event)->void:
	var eventNode:VBoxContainer = ActionControl.instance()
	var Parent:VBoxContainer = ActionNodes[action] #Action represented parent node
	Parent.add_child(eventNode)
	
	var ControlText:Label = eventNode.find_node("ControlText")
	var Remove:Button = eventNode.find_node("RemoveControl")
	
	ControlText.text = get_InputEvent_name(event)
	Remove.connect("pressed", self, "remove_control", [[action, event, eventNode]]) #Name, event, node

func remove_control(action, event, eventNode)->void:
	print("remove control = ", action)
	pass

func add_control(action)->void:
	print("new control from action = ", action)
	pass

func get_InputEvent_name(event:InputEvent)->String:
	var text:String = ""
	if event is InputEventKey:
		text = "Keyboard: " + event.as_text()
	elif event is InputEventJoypadButton:
		text = "Gamepad: "
		if Input.is_joy_known(event.device):
			text+= str(Input.get_joy_button_string(event.button_index))
		else:
			text += "Btn. " + str(event.button_index)
	elif event is InputEventJoypadMotion:
		text = "Gamepad: "
		var stick: = ''
		if Input.is_joy_known(event.device):
			stick = str(Input.get_joy_axis_string(event.axis))
			text+= stick + " "
		else:
			text += "Axis: " + str(event.axis) + " "
		
		if !stick.empty():	#known
			var value:int = round(event.axis_value)
			if stick.ends_with('X'):
				if value > 0:
					text += 'Rigt'
				else:
					text += 'Left'
			else:
				if value > 0:
					text += 'Down'
				else:
					text += 'Up'
		else:
			text += str(round(event.axis_value))
	
	return text


func _on_CancelButton_pressed():
	get_tree().change_scene("res://main_menu/main_menu.tscn")

