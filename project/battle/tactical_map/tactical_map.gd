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


var map_height: int = 100
var map_widht: int = 100


func _ready():
	randomize()
	var a = randi() % 2
	
	if a == 0:
		var randomMapGenerator = RandomMapGenerator.new(map_height, map_widht,
			$Soil, $Obstacles, $Vegetation)
		randomMapGenerator._create_forest_glade()
	else:
		var noiseMapGenerator = NoiseMapGenerator.new(map_height, map_widht,
			$Soil, $Obstacles, $Vegetation)
		noiseMapGenerator._generate_map()


class AbstractMapGenerator:
	var map_height: int
	var map_widht: int
	
	var soil: GridMap
	var obstacles: GridMap
	var vegetation: GridMap
	
	func _init(_map_height, _map_widht, _soil, _obstacles, _vegetation):
		map_height =_map_height
		map_widht =_map_widht
		
		soil = _soil
		obstacles = _obstacles
		vegetation = _vegetation

class RandomMapGenerator:
	extends AbstractMapGenerator
	
	func _init(_map_height, _map_widht, _soil, _obstacles, _vegetation).(
		_map_height, _map_widht, _soil, _obstacles, _vegetation
	):
		pass
		
	func _create_forest_glade() -> void:
		# SOIL ITEMS
		var grass_cells = _generate_item_coordinates(2)
		_set_soil_cells_item(grass_cells, ITEM_SOIL.GRASS)
		
		var dirt_cells = _generate_item_coordinates(0.3)
		_set_soil_cells_item(dirt_cells, ITEM_SOIL.DIRT)
		
		# OBSTACLES ITEMS
		var dead_oak_cells = _generate_item_coordinates(0.001)
		_set_obstacles_cells_items(dead_oak_cells, ITEM_OBSTACLES.DEAD_OAK_1,
			ITEM_OBSTACLES.DEAD_OAK_2, ITEM_OBSTACLES.DEAD_OAK_3
		)
		
		var dead_spruce_cells = _generate_item_coordinates(0.001)
		_set_obstacles_cells_items(dead_spruce_cells, ITEM_OBSTACLES.DEAD_SPRUCE_1,
			ITEM_OBSTACLES.DEAD_SPRUCE_2, ITEM_OBSTACLES.DEAD_SPRUCE_3
		)
		
		var oak_tree_cells = _generate_item_coordinates(0.01)
		_set_obstacles_cells_items(oak_tree_cells, ITEM_OBSTACLES.OAK_TREE_1,
			ITEM_OBSTACLES.OAK_TREE_2, ITEM_OBSTACLES.OAK_TREE_3
		)
		
		var spruce_tree_cells = _generate_item_coordinates(0.01)
		_set_obstacles_cells_items(spruce_tree_cells, ITEM_OBSTACLES.SPRUCE_TREE_1,
			ITEM_OBSTACLES.SPRUCE_TREE_2, ITEM_OBSTACLES.SPRUCE_TREE_3
		)
		
		var stone_cells = _generate_item_coordinates(0.003)
		_set_obstacles_cells_items(stone_cells, ITEM_OBSTACLES.STONE_1,
			ITEM_OBSTACLES.STONE_2, ITEM_OBSTACLES.STONE_3
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
			soil.set_cell_item(cell[0], 0, cell[1], _item)


	func _set_obstacles_cells_items(
			_cells: Array,
			_item1: int,
			_item2: int,
			_item3: int
		) -> void:
		var random_index: int 
		for cell in _cells:
			random_index = randi() % 3
#			var r = Basis(Vector3(0,1,0), fmod(randf(), 2*PI))
##			print("QWERTY: ", r)
#			r = r.get_orthogonal_index()
##			print(r)
			match random_index:
				0:
					obstacles.set_cell_item(cell[0], 0, cell[1], _item1)
				1:
					obstacles.set_cell_item(cell[0], 0, cell[1], _item2)
				2:
					obstacles.set_cell_item(cell[0], 0, cell[1], _item3)


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
					vegetation.set_cell_item(cell[0], 0, cell[1], _item1)
				1:
					vegetation.set_cell_item(cell[0], 0, cell[1], _item2)
				2:
					vegetation.set_cell_item(cell[0], 0, cell[1], _item3)
				3:
					vegetation.set_cell_item(cell[0], 0, cell[1], _item4)
				4:
					vegetation.set_cell_item(cell[0], 0, cell[1], _item5)
				5:
					vegetation.set_cell_item(cell[0], 0, cell[1], _item6)


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
					vegetation.set_cell_item(cell[0], 0, cell[1], _item1)
				1:
					vegetation.set_cell_item(cell[0], 0, cell[1], _item2)
				2:
					vegetation.set_cell_item(cell[0], 0, cell[1], _item3)
				3:
					vegetation.set_cell_item(cell[0], 0, cell[1], _item4)


	func _generate_item_coordinates(weight: float,
			_map_widht=map_widht, _map_height=map_height) -> Array:
		var result: Array
		
		for x in _map_widht:
			for y in _map_height:
				var r = randf()
				if r < weight:
					var c = offset_to_origin(x, y)
					result.append(c)
		return result

	func offset_to_origin(x: int, y: int) -> Array:
		var x_norm: int = x - map_widht/2
		var y_norm: int = y - map_height/2
		return [x_norm, y_norm]


class NoiseMapGenerator:
	extends AbstractMapGenerator
	var noise: OpenSimplexNoise
	
	func _init(_map_height, _map_widht, _soil, _obstacles, _vegetation).(
		_map_height, _map_widht, _soil, _obstacles, _vegetation
	):
		noise = OpenSimplexNoise.new()
		# Configure
		noise.seed = randi()
		noise.octaves = 4
		noise.period = 20.0
		noise.persistence = 0.8
	
	func _generate_map(_map_widht=map_widht, _map_height=map_height):
		var n: float
		
		for x in _map_widht:
			for y in _map_height:
				n = noise.get_noise_2d(x, y)
				var cell = offset_to_origin(x,y)
				_noise_parsing(cell, n)
	
	func _noise_parsing(_cell: Array, _n):
		if _n >= 0.0:
			soil.set_cell_item(_cell[0], 0, _cell[1], ITEM_SOIL.GRASS)
			
			var r = randf()
			if r < 0.002:
				obstacles.set_cell_item(_cell[0], 0, _cell[1],
					ITEM_OBSTACLES.OAK_TREE_3)
			elif r < 0.006:
				obstacles.set_cell_item(_cell[0], 0, _cell[1],
					ITEM_OBSTACLES.OAK_TREE_1)
			elif r < 0.009:
				obstacles.set_cell_item(_cell[0], 0, _cell[1],
					ITEM_OBSTACLES.OAK_TREE_2)
			
		else:
			soil.set_cell_item(_cell[0], 0, _cell[1], ITEM_SOIL.DIRT)
			
			var r3 = randf()
			if r3 < 0.004:
				obstacles.set_cell_item(_cell[0]+1, 0, _cell[1],
							ITEM_OBSTACLES.STONE_3)
			
			var r = randf()
			if r < 0.001:
				obstacles.set_cell_item(_cell[0], 0, _cell[1],
					ITEM_OBSTACLES.DEAD_OAK_3)
				var r2 = randi() % 2
				match r2:
					1:
						obstacles.set_cell_item(_cell[0]+1, 0, _cell[1],
							ITEM_OBSTACLES.STONE_1)
					2:
						obstacles.set_cell_item(_cell[0], 0, _cell[1]-1,
							ITEM_OBSTACLES.STONE_2)
			elif r < 0.004:
				var r1 = randi() % 2
				match r1:
					0:
						obstacles.set_cell_item(_cell[0], 0, _cell[1],
							ITEM_OBSTACLES.DEAD_SPRUCE_1)
					1:
						obstacles.set_cell_item(_cell[0], 0, _cell[1],
							ITEM_OBSTACLES.DEAD_OAK_1)
			elif r < 0.005:
				obstacles.set_cell_item(_cell[0], 0, _cell[1],
					ITEM_OBSTACLES.DEAD_SPRUCE_2)
	
	
	func offset_to_origin(x: int, y: int) -> Array:
		var x_norm: int = x - map_widht/2
		var y_norm: int = y - map_height/2
		return [x_norm, y_norm]
