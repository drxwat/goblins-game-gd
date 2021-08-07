extends Spatial


const item_soil = {
	"dirt": 0, 
	"grass": 1,
}
const item_obstacles = {
	"DeadOak1": 0,
	"DeadOak2": 1,
	"DeadOak3": 2,
	
	"DeadSpruce1": 3,
	"DeadSpruce2": 4,
	"DeadSpruce3": 5,
	
	"OakTree1": 6,
	"OakTree2": 7,
	"OakTree3": 8,
	
	"SpruceTree1": 9,
	"SpruceTree2": 10,
	"SpruceTree3": 11,
	
	"stone_2": 12,
	"stone_3": 13,
	"stones_1": 14,
}
const item_vegetation = {
	"Grass_01": 0,
	"Grass_02": 1,
	"Grass_03": 2,
	"Grass_04": 3,
	"Grass_05": 4,
	"Grass_06": 5,
	
	"Mushroom_01": 6,
	"Mushroom_02": 7,
	"Mushroom_03": 8,
	"Mushroom_04": 9,
}

onready var map_height: int = 100
onready var map_widht: int = 100


func _ready():
	_create_forest_glade()


func _create_forest_glade() -> void:
	# SOIL ITEMS
	var grass_cells = _generate_item_coordinates(2)
	_set_soil_cells_item(grass_cells, item_soil["grass"])
	
	var dirt_cells = _generate_item_coordinates(0.3)
	_set_soil_cells_item(dirt_cells, item_soil["dirt"])
	
	# OBSTACLES ITEMS
	var dead_oak_cells = _generate_item_coordinates(0.001)
	_set_obstacles_cells_items(dead_oak_cells, item_obstacles["DeadOak1"],
		item_obstacles["DeadOak2"], item_obstacles["DeadOak3"]
	)
	
	var dead_spruce_cells = _generate_item_coordinates(0.001)
	_set_obstacles_cells_items(dead_spruce_cells, item_obstacles["DeadSpruce1"],
		item_obstacles["DeadSpruce2"], item_obstacles["DeadSpruce3"]
	)
	
	var oak_tree_cells = _generate_item_coordinates(0.01)
	_set_obstacles_cells_items(oak_tree_cells, item_obstacles["OakTree1"],
		item_obstacles["OakTree2"], item_obstacles["OakTree3"]
	)
	
	var spruce_tree_cells = _generate_item_coordinates(0.01)
	_set_obstacles_cells_items(spruce_tree_cells, item_obstacles["SpruceTree1"],
		item_obstacles["SpruceTree2"], item_obstacles["SpruceTree3"]
	)
	
	var stone_cells = _generate_item_coordinates(0.003)
	_set_obstacles_cells_items(stone_cells, item_obstacles["stone_2"],
		item_obstacles["stone_3"], item_obstacles["stones_1"]
	)
	
	# VEGETATION ITEMS
#	var grass_v_cells = _generate_item_coordinates(0.001,
#			map_widht*5, map_height*5)
#	_set_vegetation_grass_cells_items(grass_v_cells, 
#		item_vegetation["Grass_01"], item_vegetation["Grass_02"],
#		item_vegetation["Grass_03"], item_vegetation["Grass_04"],
#		item_vegetation["Grass_05"], item_vegetation["Grass_06"]
#	)
#
#	var mushrooms_cells = _generate_item_coordinates(0.01,
#			map_widht, map_height)
#	_set_mushrooms_cells_items(mushrooms_cells, 
#		item_vegetation["Mushroom_01"], item_vegetation["Mushroom_02"],
#		item_vegetation["Mushroom_03"], item_vegetation["Mushroom_04"]
#	)


func _set_soil_cells_item(_cells: Array, _item: int) -> void:
	for cell in _cells:
		$Soil.set_cell_item(cell[0], 0, cell[1], _item)


func _set_obstacles_cells_items(
		_cells: Array,
		_item1: int,
		_item2: int,
		_item3: int
	) -> void:
	var random_index: int 
	for cell in _cells:
		random_index = randi() % 3
		match random_index:
			0:
				$Obstacles.set_cell_item(cell[0], 0, cell[1], _item1)
			1:
				$Obstacles.set_cell_item(cell[0], 0, cell[1], _item2)
			2:
				$Obstacles.set_cell_item(cell[0], 0, cell[1], _item3)


func _set_vegetation_grass_cells_items(
		_cells: Array,
		_item1: int,
		_item2: int,
		_item3: int,
		_item4: int,
		_item5: int,
		_item6: int
	) -> void:
	var random_index: int 
	for cell in _cells:
		random_index = randi() % 6
		match random_index:
			0:
				$Vegetation.set_cell_item(cell[0], 0, cell[1], _item1)
			1:
				$Vegetation.set_cell_item(cell[0], 0, cell[1], _item2)
			2:
				$Vegetation.set_cell_item(cell[0], 0, cell[1], _item3)
			3:
				$Vegetation.set_cell_item(cell[0], 0, cell[1], _item4)
			4:
				$Vegetation.set_cell_item(cell[0], 0, cell[1], _item5)
			5:
				$Vegetation.set_cell_item(cell[0], 0, cell[1], _item6)


func _set_mushrooms_cells_items(
		_cells: Array,
		_item1: int,
		_item2: int,
		_item3: int,
		_item4: int
	) -> void:
	var random_index: int 
	for cell in _cells:
		random_index = randi() % 6
		match random_index:
			0:
				$Vegetation.set_cell_item(cell[0], 0, cell[1], _item1)
			1:
				$Vegetation.set_cell_item(cell[0], 0, cell[1], _item2)
			2:
				$Vegetation.set_cell_item(cell[0], 0, cell[1], _item3)
			3:
				$Vegetation.set_cell_item(cell[0], 0, cell[1], _item4)


func _generate_item_coordinates(weight: float,
		_map_widht=map_widht, _map_height=map_height) -> Array:
	var result: Array
	
	for x in _map_widht:
		for y in _map_height:
			var r = randf()
			if r < weight:
				var c = _normalize_coordinates(x, y)
				result.append(c)
	return result


func _normalize_coordinates(x: int, y: int) -> Array:
	var x_norm: int = x - map_widht/2
	var y_norm: int = y - map_height/2
	return [x_norm, y_norm]
