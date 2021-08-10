extends Node2D


onready var player: Node2D = get_node("Player")
onready var tile_map: Node2D = get_node("TileMap")
onready var units_parent = get_node("Units");
onready var GlobalMapUI = $"CanvasLayer/GlobalMapUI"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(true)
	player.connect("contacted_enemy", GlobalMapUI, "_on_contacted_enemy")


func _unhandled_input(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	
	player.set_target(get_global_mouse_position())
