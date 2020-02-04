extends Node2D


onready var unit: Node2D = get_node("Unit")
onready var tile_map: TileMap = get_node("TileMap")
onready var line: Line2D = get_node("Line2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _unhandled_input(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return

	var new_path = tile_map.get_map_path(
			unit.global_position, 
			get_global_mouse_position()
			)
	
	# Drawing path line
	var line_path = PoolVector2Array(new_path)
	line_path[-1] = get_global_mouse_position()
	line.points = line_path
	
	# Path post processing
	new_path = move_path_point_to_tile_borders(new_path)
	if (tile_map.is_point_inside_map(get_global_mouse_position())):
		if (new_path.size() == 0):
			new_path = PoolVector2Array([get_global_mouse_position()])
		else:
			new_path[-1] = get_global_mouse_position()
	
	
	line.points = new_path
	unit.set_path(new_path, tile_map.get_path_weights(new_path))


# Adjusts path points from the center of the tile to it's border towards next tile
# It forces terrain weight to affect only within the tile
func move_path_point_to_tile_borders(path: PoolVector2Array):
	var new_path = []
	for i in range(1, path.size()):
		new_path.append(path[i - 1].linear_interpolate(path[i], 0.5))
	return PoolVector2Array(new_path)


