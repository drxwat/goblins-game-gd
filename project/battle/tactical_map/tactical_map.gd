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


func generate_map():
	clear_map()
	var noiseMapGenerator = TacticalMapGenerator.new(self)
	noiseMapGenerator._generate_map()


func clear_map():
	$Soil.clear()
	$Obstacles.clear()
	$Vegetation.clear()


func _on_GenButton_pressed():
	generate_map()
