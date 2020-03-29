extends Spatial

const RAY_LENGTH = 1000

onready var camera = $Camera
onready var goblin = $Goblin
onready var gridMap = $GridMap

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _unhandled_input(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
		
	var from = camera.project_ray_origin(event.position)
	var to = from + camera.project_ray_normal(event.position) * RAY_LENGTH
	var space_state = camera.get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], 1)
	
	if result:
		var path = gridMap.get_map_path(goblin.global_transform.origin, result.position)
		goblin.set_path(path)
