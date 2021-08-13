extends Spatial


enum ITEM_SOIL { DIRT, GRASS}
enum ITEM_OBSTACLES {
	DEAD_OAK_1,
	DEAD_OAK_2,
	DEAD_OAK_3,
	
	DEAD_SPRUCE_1,
	DEAD_SPRUCE_2,
	DEAD_SPRUCE_3,
	
	OAK_TREE_1,
	OAK_TREE_2,
	OAK_TREE_3,
	
	SPRUCE_TREE_1,
	SPRUCE_TREE_2,
	SPRUCE_TREE_3,
	
	STONE_1,
	STONE_2,
	STONE_3
}
enum ITEM_VEGETATION {
	GRASS_1,
	GRASS_2,
	GRASS_3,
	GRASS_4,
	GRASS_5,
	GRASS_6,
	
	MUSHROOM_1,
	MUSHROOM_2,
	MUSHROOM_3,
	MUSHROOM_4
}

var map_widht: int = 70
var map_height: int = 70

var cell_size: Vector2 = Vector2(2, 2)

var grass_game_count: int = 600000
var grass_area: Vector2 = Vector2(map_widht*2, map_height*2)
var grass_blade_height: Vector2 = Vector2(0.5, 0.5) # rand_range(x, y)
var grass_blade_width: Vector2 = Vector2(0.01, 0.2) # rand_range(x, y)
var _amount_blade_in_cell: int

onready var grass: Spatial = $Grass

onready var soil: GridMap = $Soil
onready var obstacles: GridMap = $Obstacles
onready var vegetation: GridMap = $Vegetation


onready var astar := AStar.new()

var terrain_obj := {} # tracking object types


func _ready():
	randomize()

func init_map():
	$VBoxContainer.hide()
	$Camera.hide()
	
	generate_map()
	_init_astar()


func generate_map():
	clear_map()
	
	var noiseMapGenerator = TacticalMapGenerator.new(self,
		soil, obstacles, vegetation)
	noiseMapGenerator.generate_map()
	
	var amount: int = noiseMapGenerator.get_amount_grass_cells()
	_amount_blade_in_cell = grass_game_count / amount
	_amount_blade_in_cell = ceil(_amount_blade_in_cell)
	
	grass.game_count = grass_game_count
	grass.area = grass_area
	grass.blade_height = grass_blade_height
	grass.blade_width = grass_blade_width
	grass.generate()


func clear_map():
	soil.clear()
	obstacles.clear()
	vegetation.clear()


func _on_GenButton_pressed():
	generate_map()


func is_grass_soil(_global_v: Vector3) -> bool:
	var result: bool = false
	
	var cell = soil.world_to_map(_global_v)
	if (cell in soil.get_used_cells() and
	soil.get_cell_item(cell.x, cell.y, cell.z) == ITEM_SOIL.GRASS):
		result = true
	
	return result


func get_global_coord_used_grass_cells():
	var used_cells: Array = soil.get_used_cells()
	var global_coord_used_grass_cells: Array
	
	var item: int
	var global_coord_item: Vector3
	
	for cell in used_cells:
		item = soil.get_cell_item(cell.x, cell.y, cell.z)
		if item == ITEM_SOIL.GRASS:
			global_coord_item = soil.map_to_world(cell.x, cell.y, cell.z)
			global_coord_used_grass_cells.append(global_coord_item)
	
	return global_coord_used_grass_cells


########

func get_map_path(from: Vector3, to: Vector3) -> PoolVector3Array:
	return astar.get_point_path(
			astar.get_closest_point(from), 
			astar.get_closest_point(to)
			)

func get_path_from_unit_to_unit(from_unit: BattleUnit, to_unit: BattleUnit) -> PoolVector3Array:
	free_point_from_unit(from_unit.global_transform.origin)
	free_point_from_unit(to_unit.global_transform.origin)
	var path = get_map_path(from_unit.global_transform.origin, to_unit.global_transform.origin)
	occupy_point_with_unit(from_unit.global_transform.origin, from_unit.id)
	occupy_point_with_unit(to_unit.global_transform.origin, to_unit.id)
	return path


func get_map_cell_center(point: Vector3) -> Vector3:
	var astar_point = astar.get_closest_point(point, true)
	return astar.get_point_position(astar_point);
	 
func get_cell_position(cell: Vector3) -> Vector3:
	var point = soil.map_to_world(cell.x, cell.y, cell.z)
	return astar.get_point_position(astar.get_closest_point(point)); 

func set_obstacles():
	for cell in obstacles.get_used_cells():
		var point_id = astar.get_closest_point(
			obstacles.map_to_world(cell.x, cell.y, cell.z)
		)
		astar.set_point_disabled(point_id)
		
		_register_terrain_object(
			cell,
			BattleConstants.TERRAIN_OBJECTS.OBSTACLE,
			0
		)
	

func register_unit(point: Vector3, unit_id: int):
	_register_terrain_object(soil.world_to_map(point),
		BattleConstants.TERRAIN_OBJECTS.UNIT,
		unit_id
	)

func unregister_unit(point: Vector3):
	_unregister_terrain_object(soil.world_to_map(point))

func occupy_point_with_unit(point: Vector3, unit_id: int):
	astar.set_point_disabled(astar.get_closest_point(point))
	
func free_point_from_unit(point: Vector3):
	astar.set_point_disabled(astar.get_closest_point(point, true), false)

func is_point_walkable(point: Vector3) -> bool:
	return !astar.is_point_disabled(astar.get_closest_point(point))
	
func get_neighbor_walkable_point(point: Vector3):
	var cell = soil.world_to_map(point)
	var neighbors = [
		Vector3(1, 0, 0),
		Vector3(0, 0, 1),
		Vector3(1, 0, 1),
		Vector3(-1, 0, 0),
		Vector3(-1, 0, 1)
	]
	for neighbor in neighbors:
		var n_cell = cell + neighbor
		var n_point = soil.map_to_world(n_cell.x, n_cell.y, n_cell.z)
		var is_valid = soil.get_cell_item(n_cell.x, n_cell.y, n_cell.z) != GridMap.INVALID_CELL_ITEM
		var is_walkable = is_point_walkable(n_point)
		if is_valid and is_walkable:
			return n_point
	push_error("Point %s has no available neighbors" % point)
	return null

func get_terrain_object(point: Vector3) -> int:
	var t_obj_key = _get_t_object_key(soil.world_to_map(point))
	return terrain_obj.get(
		t_obj_key,
		{
			"ID": 0,
			"TYPE": BattleConstants.TERRAIN_OBJECTS.FREE
		}
	)

func _init_astar():
	var soil_cells = soil.get_used_cells()
	var indexes_map = {}
	
	for i in range(soil_cells.size()):
		var cell = soil.map_to_world(soil_cells[i].x, soil_cells[i].y, soil_cells[i].z)
		indexes_map[cell] = i
		astar.add_point(i, cell)


	# Connecting neighbouring points
	for cell in soil_cells:
		var neighbours = [
			Vector3(cell.x + 1, cell.y,  cell.z),
			Vector3(cell.x, cell.y, cell.z + 1),
			Vector3(cell.x + 1, cell.y, cell.z + 1),
			Vector3(cell.x - 1, cell.y, cell.z + 1),
			]
		
		for neghbour in neighbours:
			if (soil.get_cell_item(neghbour.x, neghbour.y, neghbour.z) == GridMap.INVALID_CELL_ITEM):
				continue
			
			astar.connect_points(
					indexes_map[soil.map_to_world(cell.x, cell.y, cell.z)], 
					indexes_map[soil.map_to_world(neghbour.x, neghbour.y, neghbour.z)]
					)

func _get_t_object_key(cell: Vector3) -> String:
	return "%s-%s" % [cell.x, cell.z]
	
func _register_terrain_object(
		cell: Vector3,
		obj_type: int,
		obj_id: int
	):
	terrain_obj[_get_t_object_key(cell)] = { "ID": obj_id, "TYPE": obj_type }
	
func _unregister_terrain_object(cell: Vector3):
	terrain_obj.erase(_get_t_object_key(cell))
