extends Node2D


onready var player: Node2D = get_node("Player")
onready var tile_map: Node2D = get_node("TileMap")
onready var units_parent = get_node("Units");

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)


func _unhandled_input(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	
	player.set_target(get_global_mouse_position())
