extends Enemy
class_name CityGuard

var home_city: City
var patrol_destination: Vector2
var last_patrol_point: Vector2


func _ready():
	_behavior = Behavior.PATROL


func _on_process(delta):
	_apply_city_unit_behavior()
	._on_process(delta)


func _apply_city_unit_behavior():
	pass


func _get_in_guard_behavior() -> int:
	return Behavior.FOLLOW


func _get_out_guard_behavior() -> int:
	return Behavior.GO_TO
