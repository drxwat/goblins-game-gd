extends Node2D


enum GENERAL_TILESET {
	GRASS,
	BUSH_LIGHT = 4,
	BUSH_DARK,
	BIG_TREE_LIGHT = 9,
	BIG_TREE_DARK,
	BIG_TREE_YELLOW
}

enum SETTLEMENTS {
	CITY
}

const map_height = 64
const map_widht = 64

const min_number_cities = 8
const bias_number_cities = 4

onready var soil: TileMap = $Soil
onready var forest: TileMap = $Forest
onready var settlements: TileMap = $Settlements
onready var road: TileMap = $Road


func _ready():
	generate_map()
	pass


func generate_map():
	clear_map()
	var mapGenerator = WorldMapGenerator.new(self,
		soil, forest, settlements, road
	)
	mapGenerator.generate_map()


func clear_map():
	soil.clear()
	forest.clear()
	settlements.clear()
	road.clear()


func _on_Button_pressed():
	generate_map()
