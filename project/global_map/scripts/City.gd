extends Reference
class_name City

var id: int
var cell: Vector2
var location: Vector2
var other_cities: Array # Array of tupples [path_to_city: PoolVector2Array: city: City]

var economical_level := 1
var economical_power := 0
var production_amount := 0
var production_limit := 50
var max_patrolls := 3
var max_traiders := 0

var patrolls = []
var traiders = []


func _init(_id: int, _cell: Vector2, _location: Vector2):
	id = _id
	cell = _cell
	location = _location


func tick():
	if patrolls.size() < max_patrolls and \
	(patrolls.size() < traiders.size() or traiders.size() == max_traiders):
		spawn_city_guard()
		return
	if traiders.size() < max_traiders:
		spawn_city_traider()
		return

func spawn_city_guard():
	print("spawning city guard")
	pass


func spawn_city_traider():
	print("spawning city traider")
	pass


func on_city_traider_arrive(guard: Enemy):
	pass


func on_city_guard_arrive(guard: Enemy):
	print("Mommy, I'm at home")


func on_peasant_arrive():
	pass


