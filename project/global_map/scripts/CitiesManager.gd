extends Reference
class_name CitiesManager

const MAX_PATROLLS = 4

var cities_cells: Array
var buildings_tm: TileMap

var cities_routes_graph := AStar2D.new()
var cities := {}

func _init(_buildings_tm: TileMap, cities_map_index: int):
	buildings_tm = _buildings_tm
	cities_cells = buildings_tm.get_used_cells_by_id(cities_map_index)
	
	var next_city_id = 0
	var cell_to_city = {}
	for city_cell in cities_cells:
		var city = City.new(next_city_id, city_cell)
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
			other_cities.append([i_city.distance_to(j_city) ,city_to])
			cities_routes_graph.connect_points(city_from.id, city_to.id)
		other_cities.sort_custom(TuppleSorter, "sort_ascending")
		city_from.other_cities = other_cities
		


class TuppleSorter:
	static func sort_ascending(a, b):
		if a[0] < b[0]:
			return true
		return false
