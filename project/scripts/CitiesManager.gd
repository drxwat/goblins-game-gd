extends Reference

const MAX_PATROLLS = 4

var cities_cells: Array
var buildings_tm: TileMap


func _init(_buildings_tm: TileMap, cities_map_index: int):
	buildings_tm = _buildings_tm
	cities_cells = buildings_tm.get_used_cells_by_id(cities_map_index)


class City:
	
	var patrolls = []
	var traiders = []
	var neighbour_cities: Array
	
	func _init(_neighbour_cities: Array, max_patrolls: int):
		neighbour_cities = _neighbour_cities

	
	func create_patroll():
		pass
