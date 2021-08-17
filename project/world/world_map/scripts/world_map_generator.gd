class_name WorldMapGenerator
extends Reference


var WorldMap: Node2D
var noise: OpenSimplexNoise

var soil: TileMap
var forest: TileMap
var settlements: TileMap
var road: TileMap

var not_forest_cells: Array
var path_road: Array

var astar: AStar


func _init(_world_map, _soil, _forest, _settlements, _road):
	WorldMap = _world_map
	
	soil = _soil
	forest = _forest
	settlements = _settlements
	road = _road
	
	astar = AStar.new()
	
	noise = OpenSimplexNoise.new()
	# Configure
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8


func generate_map(
	_map_widht=WorldMap.map_widht,
	_map_height=WorldMap.map_height
) -> void:
	_generate_soil(_map_widht, _map_height)
	_generate_forest(_map_widht, _map_height)
	_generate_settlements(_map_widht, _map_height)


func _generate_soil(_map_widht, _map_height) -> void:
	var _cell: Vector2
	
	for x in _map_widht:
		for y in _map_height:
			_cell = offset_to_origin(x,y)
			soil.set_cellv(
				_cell,
				WorldMap.GENERAL_TILESET.GRASS
			)


func _generate_forest(_map_widht, _map_height) -> void:
	var _cell: Vector2
	var n
	
	for x in _map_widht:
		for y in _map_height:
			n = noise.get_noise_2d(x, y)
			_cell = offset_to_origin(x,y)
			if n >0:
				if (randi() % 100) < 70:
					forest.set_cellv(
						_cell,
						_get_random_tree()
					)
				else:
					not_forest_cells.append(_cell)
			else:
				not_forest_cells.append(_cell)
				


func _get_random_tree() -> int:
	var n = randi() % 100
	var result: int
	
	if n < 9:
		result = WorldMap.GENERAL_TILESET.BIG_TREE_YELLOW
	elif n < 60:
		result = WorldMap.GENERAL_TILESET.BIG_TREE_DARK
	else:
		result = WorldMap.GENERAL_TILESET.BIG_TREE_LIGHT
	
	return result


func _generate_settlements(_map_widht, _map_height) -> void:
	var random_x: int
	var random_y: int
	var random_index: int
	var cell: Vector2
	
	var number_existing_cities: int = 0
	
	var number_cities: int
	number_cities = WorldMap.min_number_cities
	number_cities += randi() % (WorldMap.bias_number_cities + 1)
	
	while(number_existing_cities != number_cities):
		random_index = randi() % not_forest_cells.size()
		cell = not_forest_cells[random_index]
		
		if (is_empty_cell(cell) and
			is_empty_cell(Vector2(cell.x, cell.y-1)) and
			is_soil(Vector2(cell.x, cell.y-1))
		):
			settlements.set_cellv(
				cell,
				WorldMap.SETTLEMENTS.CITY
			)
			number_existing_cities += 1
	
	_init_astar()
	set_obstacles(forest)
	set_obstacles(settlements)
	_make_path_for_settlements()
	_create_roads()
	
	

func _init_astar() -> void:
	var soil_cells = soil.get_used_cells()
	var indexes_map = {}
	
	for i in range(soil_cells.size()):
		var cell = soil.map_to_world(soil_cells[i])
		var weight: float
		indexes_map[cell] = i
		astar.add_point(i, Vector3(cell.x, 0, cell.y), 8.0)


	# Connecting neighbouring points
	for cell in soil_cells:
		var neighbours = [
			Vector2(cell.x + 1,  cell.y),
			Vector2(cell.x, cell.y + 1),
			Vector2(cell.x + 1, cell.y + 1),
			Vector2(cell.x - 1, cell.y + 1),
			]
		
		for neghbour in neighbours:
			if (soil.get_cell(neghbour.x, neghbour.y) == TileMap.INVALID_CELL):
				continue
			
			astar.connect_points(
					indexes_map[soil.map_to_world(cell)], 
					indexes_map[soil.map_to_world(neghbour)]
					)


func set_obstacles(_obstacles) -> void:
	for cell in _obstacles.get_used_cells():
		var c = _obstacles.map_to_world(cell)
		var point_id = astar.get_closest_point(
			Vector3(c.x, 0, c.y)
		)
		astar.set_point_disabled(point_id)


func _make_path_for_settlements() -> void:
	var from = settlements.get_used_cells()[1]
	var to = settlements.get_used_cells()[2]
	
	var a = settlements.get_used_cells()
	a.resize(2)
	
	for s in a:
		for s1 in settlements.get_used_cells():
			from = s1
			to = s
			
			var path: PoolVector3Array = get_path_from_settlement_to_settlement(from, to)
			
			for p in path:
				var points_i: Array = astar.get_points()
				var points: Array
				for p_i in points_i:
					points.append(astar.get_point_position(p_i))
				
				var i = points.find(p)
				astar.set_point_weight_scale(i, 1.0)
				path_road.append(road.world_to_map(Vector2(p.x, p.z)))



func get_path_from_settlement_to_settlement(
	from: Vector2, to: Vector2
) -> PoolVector3Array:
	var from_v: Vector2 = settlements.map_to_world(from)
	var to_v: Vector2 = settlements.map_to_world(to)
	var path = get_map_path(
		Vector3(from_v.x, 0, from_v.y),
		Vector3(to_v.x, 0, to_v.y)
	)
	return path


func get_map_path(_from: Vector3, _to: Vector3) -> PoolVector3Array:
	return astar.get_point_path(
			astar.get_closest_point(_from), 
			astar.get_closest_point(_to)
			)


func _create_roads() -> void:
	for cell in path_road:
		road.set_cellv(cell, 2) 
#		forest.set_cellv(cell,4) # temporarity


func is_empty_cell(_cell) -> bool:
	var result: bool = false
	
	if (not is_forest(_cell)) and (not is_settlements(_cell)):
		result = true
	
	return result


func is_soil(_cell) -> bool:
	var result: bool = false
	
	if soil.get_cellv(_cell) != forest.INVALID_CELL:
		result = true
	
	return result


func is_forest(_cell) -> bool:
	var result: bool = false
	
	if forest.get_cellv(_cell) != forest.INVALID_CELL:
		result = true
	
	return result

func is_settlements(_cell) -> bool:
	var result: bool
	
	if settlements.get_cellv(_cell) != settlements.INVALID_CELL:
		result = true
	else:
		result = false
	
	return result


func offset_to_origin(x: int, y: int) -> Vector2:
	var x_norm: int = x - WorldMap.map_widht/2
	var y_norm: int = y - WorldMap.map_height/2
	return Vector2(x_norm, y_norm)

