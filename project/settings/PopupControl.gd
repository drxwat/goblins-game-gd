extends Popup

signal NewControl

var NewEvent:InputEvent

func _ready()->void:
	popup_exclusive = true
	set_process_input(false)
	connect("about_to_show", self, "receive_input")
	connect("popup_hide", self, "receive_focus")

func receive_input()->void:
	set_process_input(true)

func receive_focus()->void:
	print_debug("close popup")

func _input(event)->void:
	if !event is InputEventKey && !event is InputEventJoypadButton && !event is InputEventJoypadMotion:
		return
	if !event.is_pressed():
		return
	NewEvent = event
	emit_signal("NewControl")
	set_process_input(false)
	visible = false
