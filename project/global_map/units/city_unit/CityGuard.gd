extends Enemy
class_name CityGuard

var home_city: City


func _handle_guard_area_violation(unit: Node2D):
	follow(unit)


func _handle_guard_area_free():
	resume_patrol()


func _switch_to_default_behavior():
	patrol()


func _on_interrupt_behavior(behavior: int):
	if behavior == Behavior.PATROL and is_patrol_over():
		home_city.on_city_guard_arrive(self)
		idle()
