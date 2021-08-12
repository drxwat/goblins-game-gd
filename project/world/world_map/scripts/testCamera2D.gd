extends Camera2D

const SPEED = 20

func _ready():
	pass

func _process(delta):
	if Input.is_action_pressed("ui_right"):
		position.x += SPEED
	if Input.is_action_pressed("ui_left"):
		position.x -= SPEED
	if Input.is_action_pressed("ui_down"):
		position.y += SPEED
	if Input.is_action_pressed("ui_up"):
		position.y -= SPEED
