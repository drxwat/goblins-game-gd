extends Reference
class_name City

const FRACTION_OF_TRADE_PARTNERS = 0.4

signal exit_city
signal enter_city

var rng = RandomNumberGenerator.new()
var city_guard_scene: PackedScene = preload("res://global_map/units/city_guard/CityGuard.tscn")
var city_traider_scene: PackedScene = preload("res://global_map/units/city_traider/CityTraider.tscn")

var id: int
var cell: Vector2
var location: Vector2
var other_cities: Array # Array of tupples [path_to_city: PoolVector2Array: city: City]

var economical_level := 1
var economical_power := 0
var production_amount := 0
var production_limit := 50
var max_guards := 1
var max_traiders := 3

var traiders = []
var idle_traiders = []
var foreign_traiders = []
var guards = []
var idle_guards = []


func _init(_id: int, _cell: Vector2, _location: Vector2):
	id = _id
	cell = _cell
	location = _location
	rng.randomize()


func tick():
	if guards.size() < max_guards and \
	(guards.size() < traiders.size() or traiders.size() == max_traiders):
		spawn_guard()
		return
	if traiders.size() < max_traiders:
		spawn_traider()
		return
		
	if not idle_guards.empty():
		send_guard()
		return
	if not foreign_traiders.empty():
		send_foregn_traider_back()
		return
	if not idle_traiders.empty():
		send_traider()


# Produces new unit | TODO: Spend resourced for the new unit
func spawn_guard():
	var guard: CityGuard = city_guard_scene.instance()
	guards.append(guard)
	guard.home_city = self
	guard.set_patrol_route(get_new_guard_route())
	guard.position = location
	guard.patrol()
	emit_signal("exit_city", guard)


func send_guard():
	var guard: CityGuard = idle_guards[0]
	idle_guards.remove(0)
	guard.set_patrol_route(get_new_guard_route())
	guard.position = location
	guard.patrol()
	emit_signal("exit_city", guard)

# Produces new unit | TODO: Spend resourced for the new unit
func spawn_traider():
	var traider: CityTraider = city_traider_scene.instance()
	var target_city := get_new_tarider_city()
	traiders.append(traider)
	traider.home_city = self
	traider.set_target_city(target_city)
	traider.position = location
	traider.go_to_target_city()
	emit_signal("exit_city", traider)


func send_traider():
	var traider: CityTraider = idle_traiders[0]
	idle_traiders.remove(0)
	traider.set_target_city(get_new_tarider_city())
	traider.position = location
	traider.go_to_target_city()
	emit_signal("exit_city", traider)


func send_foregn_traider_back():
	var traider: CityTraider = foreign_traiders[0]
	foreign_traiders.remove(0)
	traider.set_target_city(traider.home_city)
	traider.position = location
	traider.go_to_target_city()
	emit_signal("exit_city", traider)


func on_city_traider_arrive(traider: CityTraider):
	if traider.home_city == self:
		idle_traiders.append(traider)
	else:
		foreign_traiders.append(traider)
	emit_signal("enter_city", traider)


func on_city_guard_arrive(guard: CityGuard):
	idle_guards.append(guard)
	emit_signal("enter_city", guard)


func on_peasant_arrive():
	pass


func get_new_tarider_city() -> City:
	var max_city_i = ceil(other_cities.size() * FRACTION_OF_TRADE_PARTNERS)
	var city_meta = other_cities[rng.randi_range(0, max_city_i)]
	return city_meta[1]


func get_new_guard_route() -> PoolVector2Array:
	var max_city_i = ceil(other_cities.size() * FRACTION_OF_TRADE_PARTNERS)
	var city_meta = other_cities[rng.randi_range(0, max_city_i)]
	return get_guard_route_from_path(city_meta[0])


func get_guard_route_from_path(path_to_the_city: PoolVector2Array) -> PoolVector2Array:
	var city_path: PoolVector2Array = path_to_the_city
	var back_route = PoolVector2Array(city_path)
	back_route.invert()
	city_path.append_array(back_route)
	return city_path
