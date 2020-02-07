extends Node2D

enum WeightScales {
	ROAD = 2,
	GRASS = 8,
	FOREST = 12  
}

const TILE_ADJ = Vector2(0, 64)

var _ground_cells_indexes = {}

onready var astar := AStar2D.new()
onready var tm_ground: TileMap = get_node("Ground")
onready var tm_road: TileMap = get_node("Road")
onready var tm_forest: TileMap = get_node("Forest")


func _ready():
	_init_terrain_grid()
	_change_cells_weights(tm_road, WeightScales.ROAD)
	_change_cells_weights(tm_forest, WeightScales.FOREST)


func get_map_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	return astar.get_point_path(
			astar.get_closest_point(from), 
			astar.get_closest_point(to)
			)


func get_path_weights(path: PoolVector2Array) -> PoolRealArray:
	var weights = []
	for point in path:
		var idx = astar.get_closest_point(point)
		weights.append(astar.get_point_weight_scale(idx))
	return PoolRealArray(weights)


func is_point_inside_map(point: Vector2):
	var map_position = tm_ground.world_to_map(point)
	return tm_ground.get_cellv(map_position) != TileMap.INVALID_CELL


func _init_terrain_grid() -> void:
	print("Terrain grid initialization...")
	
	var ground_cells = tm_ground.get_used_cells()
	ground_cells.sort()
	
	# Initializing all tiles as points for A*
	for i in range(ground_cells.size()):
		var cell = tm_ground.map_to_world(ground_cells[i]) + TILE_ADJ
		_ground_cells_indexes[cell] = i
		astar.add_point(i, cell, WeightScales.GRASS)


	# Connecting neighbouring points
	for cell in ground_cells:
		var neighbours = [
			Vector2(cell.x + 1, cell.y),
			Vector2(cell.x, cell.y + 1),
			Vector2(cell.x + 1, cell.y + 1),
			]
		
		for neghbour in neighbours:
			if (tm_ground.get_cellv(neghbour) == TileMap.INVALID_CELL):
				continue
			
			astar.connect_points(
					_ground_cells_indexes[tm_ground.map_to_world(cell) + TILE_ADJ], 
					_ground_cells_indexes[tm_ground.map_to_world(neghbour) + TILE_ADJ]
					)


func _change_cells_weights(tm: TileMap, weight: float) -> void:
	for cell in tm.get_used_cells():
		var cell_idx = _ground_cells_indexes[tm.map_to_world(cell) + TILE_ADJ]
		astar.set_point_weight_scale(cell_idx, weight)

