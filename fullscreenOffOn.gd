#FullScreen toggle#

extends Node

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _physics_process(_delta):
	if Input.is_action_pressed("Alt") and Input.is_action_just_pressed("ui_accept"):
		OS.window_fullscreen = not OS.window_fullscreen
	elif Input.is_action_just_pressed("F11"):
		OS.window_fullscreen = not OS.window_fullscreen
