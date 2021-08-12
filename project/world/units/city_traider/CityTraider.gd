extends Enemy
class_name CityTraider

var home_city
var target_city


func set_target_city(city):
	target_city = city


func go_to_target_city():
	go_to(target_city.location)


func _handle_guard_area_violation(unit: Node2D):
	flee(unit)


func _handle_guard_area_free():
	go_to_target_city()


func _switch_to_default_behavior():
	go_to_target_city()


func _on_interrupt_behavior(behavior: int):	
	if behavior == Behavior.GO_TO and position.distance_to(target_city.location) < 10:
		target_city.on_city_traider_arrive(self)
		idle()
