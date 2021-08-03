extends MeshInstance

const neutral = Color("#24ffffff")
const enemy = Color("#24ce4444")
const obstacle = Color("#240056dc")
const ally = Color("#2468cf4b")

var current_color = neutral

onready var material := mesh.surface_get_material(0)

func _ready():
	_apply_color(neutral)
	
func hover_ally():
	_apply_color(ally)

func hover_enemy():
	_apply_color(enemy)
	
func hover_neutral():
	_apply_color(neutral)
	
func hover_obstacle():
	_apply_color(obstacle)
	
func _apply_color(new_color: Color):
	if current_color == new_color:
		return
	material.albedo_color = new_color
	current_color = new_color
