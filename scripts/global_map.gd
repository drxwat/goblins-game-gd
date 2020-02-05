extends Node2D


onready var player: Node2D = get_node("Player")
onready var tile_map: TileMap = get_node("TileMap")
onready var line: Line2D = get_node("Line2D")
onready var units_parent = get_node("Units");

onready var unit := load(Constants.UNIT_SCENE_PATH)

# Called when the node enters the scene tree for the first time.
func _ready():
	var new_unit: Node2D = unit.instance()
	units_parent.add_child(new_unit)
	new_unit.position = Vector2(0, 0)
	set_process(true)
	

func _process(delta):
	if (units_parent.get_child_count() > 0):
		for enemy in units_parent.get_children():
			move_unit_to(enemy, player.global_position)

func _unhandled_input(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	
	move_unit_to(player, get_global_mouse_position(), true)


func move_unit_to(unit: Node2D, target: Vector2, draw_line := false) -> void:
	var path = tile_map.get_map_path(
		unit.global_position, 
		target
		)
	
	# Path post processing
	path = _move_path_point_to_tile_borders(path)
	if (tile_map.is_point_inside_map(target)):
		if (path.size() == 0):
			path = PoolVector2Array([target])
		else:
			path[-1] = target
	
	if (draw_line):
		line.points = path
	
	unit.set_path(path, tile_map.get_path_weights(path))


# Adjusts path points from the center of the tile to it's border towards next tile
# It forces terrain weight to affect only within the tile
func _move_path_point_to_tile_borders(path: PoolVector2Array) -> PoolVector2Array:
	var new_path = []
	for i in range(1, path.size()):
		new_path.append(path[i - 1].linear_interpolate(path[i], 0.5))
	return PoolVector2Array(new_path)


