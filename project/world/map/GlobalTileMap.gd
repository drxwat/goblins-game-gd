extends Node2D
class_name GlobalTileMap

enum WeightScales {
	ROAD = 2,
	GRASS = 8,
	FOREST = 12  
}

const TILE_ADJ = Vector2(0, 64)

var _ground_cells_indexes = {}
var _ground_cells_raod_indexes = {}

onready var astar := AStar2D.new()
onready var astar_roads := AStar2D.new()
onready var tm_ground: TileMap = $"Ground"
onready var tm_road: TileMap = $"Road"
onready var tm_forest: TileMap = $"Forest"
onready var tm_buildings: TileMap = $"Buildings"


func _ready():
	# General terrain initialization
	_init_terrain_grid(tm_ground, astar, _ground_cells_indexes, WeightScales.GRASS)
	_change_cells_weights(tm_road, astar, _ground_cells_indexes, WeightScales.ROAD)
	_change_cells_weights(tm_forest, astar, _ground_cells_indexes, WeightScales.FOREST)
	# Roads only terrain initialization
	_init_terrain_grid(tm_road, astar_roads, 
		_ground_cells_raod_indexes, WeightScales.ROAD)


func get_map_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	return astar.get_point_path(
			astar.get_closest_point(from), 
			astar.get_closest_point(to)
			)


func get_road_path(from: Vector2, to: Vector2) -> PoolVector2Array:
	return astar_roads.get_point_path(
			astar_roads.get_closest_point(from), 
			astar_roads.get_closest_point(to)
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


func _init_terrain_grid(
		tile_map: TileMap, 
		grid_astar: AStar2D, 
		indexes_map: Dictionary, 
		weight: float
		) -> void:
	var ground_cells = tile_map.get_used_cells()
	ground_cells.sort()
	
	# Initializing all tiles as points for A*
	for i in range(ground_cells.size()):
		var cell = tile_map.map_to_world(ground_cells[i]) + TILE_ADJ
		indexes_map[cell] = i
		grid_astar.add_point(i, cell, weight)


	# Connecting neighbouring points
	for cell in ground_cells:
		var neighbours = [
			Vector2(cell.x + 1, cell.y),
			Vector2(cell.x, cell.y + 1),
			Vector2(cell.x + 1, cell.y + 1),
			]
		
		for neghbour in neighbours:
			if (tile_map.get_cellv(neghbour) == TileMap.INVALID_CELL):
				continue
			
			grid_astar.connect_points(
					indexes_map[tile_map.map_to_world(cell) + TILE_ADJ], 
					indexes_map[tile_map.map_to_world(neghbour) + TILE_ADJ]
					)


func _change_cells_weights(
		tm: TileMap, 
		grid_astar: AStar2D, 
		indexes_map: Dictionary, 
		weight: float
		) -> void:
	for cell in tm.get_used_cells():
		var cell_idx = indexes_map[tm.map_to_world(cell) + TILE_ADJ]
		grid_astar.set_point_weight_scale(cell_idx, weight)

