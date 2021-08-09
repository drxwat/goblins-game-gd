extends Unit
class_name CityPatrol

var home_city: City 
var destination: Vector2
var units : Array # GlobalUnit[]


func _ready():
	pass # Replace with function body.


func initialize(_units: Array):
	units = _units


