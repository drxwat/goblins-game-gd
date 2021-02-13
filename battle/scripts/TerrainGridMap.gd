extends GridMap


onready var astar := AStar.new()

var terrain_obj := {} # tracking object types

func _ready():
	_init_terrain_grid(astar)

func get_map_path(from: Vector3, to: Vector3) -> PoolVector3Array:
	return astar.get_point_path(
			astar.get_closest_point(from), 
			astar.get_closest_point(to)
			)

func get_map_cell_center(point: Vector3) -> Vector3:
	return astar.get_point_position(astar.get_closest_point(point, true));
	 
func get_cell_position(cell: Vector3) -> Vector3:
	var point = map_to_world(cell.x, cell.y, cell.z)
	return astar.get_point_position(astar.get_closest_point(point)); 

func set_obstacles(obstacles_map: GridMap):
	for cell in obstacles_map.get_used_cells():
		var point_id = astar.get_closest_point(obstacles_map.map_to_world(cell.x, cell.y, cell.z))
		astar.set_point_disabled(point_id)
		_register_terrain_object(cell, BattleConstants.TERRAIN_OBJECTS.OBSTACLE, 0)
		
func occupy_point_with_unit(point: Vector3, unit_id: int):
	_register_terrain_object(world_to_map(point), BattleConstants.TERRAIN_OBJECTS.UNIT, unit_id)
	astar.set_point_disabled(astar.get_closest_point(point))
	
func free_point_from_unit(point: Vector3):
	_unregister_terrain_object(world_to_map(point))
	astar.set_point_disabled(astar.get_closest_point(point), false)

func is_point_walkable(point: Vector3) -> bool:
	return !astar.is_point_disabled(astar.get_closest_point(point))
	
func get_neighbor_walkable_point(point: Vector3):
	var cell = world_to_map(point)
	var neighbors = [
		Vector3(1, 0, 0),
		Vector3(0, 0, 1),
		Vector3(1, 0, 1),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 1)
	]
	for neighbor in neighbors:
		var n_cell = cell + neighbor
		var n_point = map_to_world(n_cell.x, n_cell.y, n_cell.z)
		var is_valid = get_cell_item(n_cell.x, n_cell.y, n_cell.z) != INVALID_CELL_ITEM
		var is_walkable = is_point_walkable(n_point)
		if is_valid and is_walkable:
			return n_point
	push_error("Point %s has no available neighbors" % point)
	return null

func get_terrain_object(point: Vector3) -> int:
	var t_obj_key = _get_t_object_key(world_to_map(point))
	return terrain_obj.get(t_obj_key, { "ID": 0, "TYPE": BattleConstants.TERRAIN_OBJECTS.FREE })

func _init_terrain_grid(astar):
	var ground_cells = get_used_cells()
	var indexes_map = {}
	
	for i in range(ground_cells.size()):
		var cell = map_to_world(ground_cells[i].x, ground_cells[i].y, ground_cells[i].z)
		indexes_map[cell] = i
		astar.add_point(i, cell)


	# Connecting neighbouring points
	for cell in ground_cells:
		var neighbours = [
			Vector3(cell.x + 1, cell.y,  cell.z),
			Vector3(cell.x, cell.y, cell.z + 1),
			Vector3(cell.x + 1, cell.y, cell.z + 1),
			Vector3(cell.x - 1, cell.y, cell.z + 1),
			]
		
		for neghbour in neighbours:
			if (get_cell_item(neghbour.x, neghbour.y, neghbour.z) == GridMap.INVALID_CELL_ITEM):
				continue
			
			astar.connect_points(
					indexes_map[map_to_world(cell.x, cell.y, cell.z)], 
					indexes_map[map_to_world(neghbour.x, neghbour.y, neghbour.z)]
					)

func _get_t_object_key(cell: Vector3) -> String:
	return "%s-%s" % [cell.x, cell.z]
	
func _register_terrain_object(cell: Vector3, obj_type: int, obj_id: int):
	terrain_obj[_get_t_object_key(cell)] = { "ID": obj_id, "TYPE": obj_type }
	
func _unregister_terrain_object(cell: Vector3):
	terrain_obj.erase(_get_t_object_key(cell))
