extends Reference
class_name City

var id: int
var cell: Vector2
var other_cities: Array # Array of tupples [distance_to_city: float: city: City]

var economical_level := 1
var economical_power := 0
var production_amount := 0
var production_limit := 50
var max_patrolls := 3
var max_traiders := 4

var patrolls = []
var traiders = []


func _init(_id: int, _cell: Vector2):
	id = _id
	cell = _cell


func create_patroll():
	pass


func create_traider():
	pass


func on_traider_arrive():
	pass


func on_patrol_arrive():
	pass


func on_peasant_arrive():
	pass
