extends Node2D


onready var player: Node2D = get_node("Player")
onready var tile_map: Node2D = get_node("TileMap")
onready var units_parent = get_node("Units");

onready var enemy_class := load(GlobalConstants.ENEMY_SCENE_PATH)

# Called when the node enters the scene tree for the first time.
func _ready():
	var enemy: Node2D = enemy_class.instance()
	units_parent.add_child(enemy)
	enemy.position = Vector2(0, 0)
	enemy.base_speed = enemy.base_speed / 1.5
	enemy._aim = player
	set_process(true)


func _unhandled_input(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	
	player.set_target(get_global_mouse_position())
