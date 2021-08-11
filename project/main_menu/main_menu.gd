extends CanvasLayer

var visible = true setget set_visible

func set_visible(val):
	visible = val
	$"MenuUI".visible = val


func _on_Button_Exit_pressed():
	get_tree().quit()


func _on_Button_Settings_pressed():
	pass # Replace with function body.


func _on_Button_Game_pressed():
	get_tree().change_scene("res://global_map/global_map.tscn")


func _ready():
	get_tree().connect("screen_resized", self, "_screen_resized")
	_screen_resized()
	$"Viewport/Spatial/GoblinBattleUnit".healtbar.visible = false


func _screen_resized():
	$"Viewport".size = get_viewport().size
