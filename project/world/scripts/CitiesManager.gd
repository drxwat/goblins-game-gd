extends Reference
class_name CitiesManager

var cities_cells: Array
var global_tile_map: GlobalTileMap

var cities_routes_graph := AStar2D.new()
var cities := {}

func _init(_global_tile_map: GlobalTileMap, cities_map_index: int):
	global_tile_map = _global_tile_map
	var buildings_tm = global_tile_map.tm_buildings
	cities_cells = buildings_tm.get_used_cells_by_id(cities_map_index)
	
	var next_city_id = 0
	var cell_to_city = {}
	for city_cell in cities_cells:
		var city = City.new(next_city_id, city_cell, buildings_tm.map_to_world(city_cell))
		cities[city.id] = city
		cell_to_city[city_cell] = city
		cities_routes_graph.add_point(city.id, buildings_tm.map_to_world(city_cell))
		next_city_id += 1

	for i_city in cities_cells:
		var city_from: City = cell_to_city.get(i_city)
		var other_cities = []
		for j_city in cities_cells:
			if i_city == j_city:
				continue
			var city_to: City = cell_to_city.get(j_city)
			var road_path = global_tile_map.get_road_path(
				city_from.location, city_to.location
			)
			other_cities.append([road_path ,city_to])
			cities_routes_graph.connect_points(city_from.id, city_to.id)
		other_cities.sort_custom(TuppleSizeSorter, "sort_ascending")
		city_from.other_cities = other_cities


class TuppleSizeSorter:
	static func sort_ascending(a, b):
		if a[0].size() < b[0].size():
			return true
		return false
