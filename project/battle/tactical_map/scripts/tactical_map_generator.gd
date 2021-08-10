class_name TacticalMapGenerator
extends Reference

const STONE_CHANCE = 0.004
const OAK_TREE_3_CHANCE = 0.002
const OAK_TREE_2_CHANCE = 0.006
const OAK_TREE_1_CHANCE = 0.009
const DEAD_OAK_CHANCE = 0.001
const DEAD_TREE_CHANCE = 0.004
const DEAD_SPRUCE_2_CHANCE = 0.005

var TacticalMap: Spatial
var noise: OpenSimplexNoise

var soil: GridMap
var obstacles: GridMap
var vegetation: GridMap


func _init(_tactical_map, _soil, _obstacles, _vegetation):
	TacticalMap = _tactical_map
	
	soil = _soil
	obstacles = _obstacles
	vegetation = _vegetation

	noise = OpenSimplexNoise.new()
	# Configure
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8

func generate_map(
		_map_widht=TacticalMap.map_widht,
		_map_height=TacticalMap.map_height
	):
	var n: float
	
	for x in _map_widht:
		for y in _map_height:
			n = noise.get_noise_2d(x, y)
			var cell = offset_to_origin(x,y)
			_noise_parsing(cell, n)

func _noise_parsing(_cell: Array, _n):
	if _n >= 0.0:
		soil.set_cell_item(_cell[0], 0, _cell[1],
			TacticalMap.ITEM_SOIL.GRASS)
		
		var r = randf()
		if r < OAK_TREE_3_CHANCE:
			obstacles.set_cell_item(_cell[0], 0, _cell[1],
				TacticalMap.ITEM_OBSTACLES.OAK_TREE_3)
		elif r < OAK_TREE_2_CHANCE:
			obstacles.set_cell_item(_cell[0], 0, _cell[1],
				TacticalMap.ITEM_OBSTACLES.OAK_TREE_1)
		elif r < OAK_TREE_1_CHANCE:
			obstacles.set_cell_item(_cell[0], 0, _cell[1],
				TacticalMap.ITEM_OBSTACLES.OAK_TREE_2)
		
	else:
		soil.set_cell_item(_cell[0], 0, _cell[1],
			TacticalMap.ITEM_SOIL.DIRT)
		
		var r3 = randf()
		if r3 < STONE_CHANCE:
			obstacles.set_cell_item(_cell[0]+1, 0, _cell[1],
						TacticalMap.ITEM_OBSTACLES.STONE_3)
		
		var r = randf()
		if r < DEAD_OAK_CHANCE:
			obstacles.set_cell_item(_cell[0], 0, _cell[1],
				TacticalMap.ITEM_OBSTACLES.DEAD_OAK_3)
			var r2 = randi() % 2
			match r2:
				1:
					obstacles.set_cell_item(_cell[0]+1, 0, _cell[1],
						TacticalMap.ITEM_OBSTACLES.STONE_1)
				2:
					obstacles.set_cell_item(_cell[0], 0, _cell[1]-1,
						TacticalMap.ITEM_OBSTACLES.STONE_2)
		elif r < DEAD_TREE_CHANCE:
			var r1 = randi() % 2
			match r1:
				0:
					obstacles.set_cell_item(_cell[0], 0, _cell[1],
						TacticalMap.ITEM_OBSTACLES.DEAD_SPRUCE_1)
				1:
					obstacles.set_cell_item(_cell[0], 0, _cell[1],
						TacticalMap.ITEM_OBSTACLES.DEAD_OAK_1)
		elif r < DEAD_SPRUCE_2_CHANCE:
			obstacles.set_cell_item(_cell[0], 0, _cell[1],
				TacticalMap.ITEM_OBSTACLES.DEAD_SPRUCE_2)


func offset_to_origin(x: int, y: int) -> Array:
	var x_norm: int = x - TacticalMap.map_widht/2
	var y_norm: int = y - TacticalMap.map_height/2
	return [x_norm, y_norm]

