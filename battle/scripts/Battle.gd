extends Spatial

const RAY_LENGTH = 1000
const MOUSE_HOVER_Y_OFFSET = Vector3(0, 0.05, 0)

onready var camera := $Camera
onready var goblin := $BattleGoblin
onready var gridMap := $Terrain
onready var mouseHover := $MouseHover

# Called when the node enters the scene tree for the first time.
func _ready():
	print(goblin)
	$Terrain.set_obstacles($Forest)


func _input(event: InputEvent):
	_handle_mouse_click(event)
	_handle_mouse_move(event)


func _handle_mouse_click(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	
	var m_position = _get_mouse_projected_position(event.position)
	if m_position:
		_move_unit(goblin, m_position)


func _handle_mouse_move(event: InputEvent):
	if not event is InputEventMouseMotion:
		return
	var m_position = _get_mouse_projected_position(event.position)
	if m_position:
		_move_mouse_hover(m_position)

func _move_unit(unit: BattleUnit, pos: Vector3):
	var path = gridMap.get_map_path(unit.global_transform.origin, pos)
	unit.set_path(path)

func _move_mouse_hover(pos: Vector3):
	mouseHover.translation = gridMap.get_map_cell_center(pos) + MOUSE_HOVER_Y_OFFSET

func _get_mouse_projected_position(screen_position: Vector2):
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * RAY_LENGTH
	var space_state = camera.get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], 1)
	
	if not result:
		return null
	return result.position
	
