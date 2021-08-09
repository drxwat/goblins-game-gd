#
# Base class for all units
# Implements movement to target
#
extends Node2D
class_name Unit



export (float) var base_speed  := 800.0

var _target: Vector2 setget set_target
var _path := PoolVector2Array()
var _path_weights := PoolRealArray()

onready var tile_map: GlobalTerrainTileMap = get_tree().get_root().get_node("Root/TileMap")

var _path_line: Line2D


func _ready():
	if GlobalConstants.DEBUG_PATH:
		var root = get_tree().get_root()
		_path_line = Line2D.new()
		_path_line.width = 5
		_path_line.default_color = _get_path_line_color()
		root.call_deferred("add_child", _path_line)

	_on_ready()


func _process(delta):
	_on_process(delta)


func _on_ready():
	pass


func _on_process(delta):
	if is_moving():
		move_along_path(delta)


func is_moving() -> bool:
	return _path and _path.size() > 0 
	

func stop_moving():
	set_target(global_position)


# Sets target Vector2 point to go to
func set_target(value: Vector2):
	if _target and _target == value:
		return
	_target = value
	var path = tile_map.get_map_path(
		self.global_position, 
		_target
		)
	
	# Path post processing
	path = _move_path_point_to_tile_borders(path)
	if tile_map.is_point_inside_map(_target):
		if (path.size() == 0):
			path = PoolVector2Array([_target])
		else:
			path[-1] = _target
	
	if GlobalConstants.DEBUG_PATH:
		var path_line_points = PoolVector2Array()
		path_line_points.append(global_position)
		path_line_points.append_array(path)
		_path_line.points = path_line_points
	
	set_path(path, tile_map.get_path_weights(path))


func move_along_path(delta: float) -> void:
	var start_point := position
	var remaining_time = delta
	for i in range(_path.size()):
		var distance_to_next := start_point.distance_to(_path[0])
		var current_speed = base_speed / _path_weights[0]
		var current_distance = current_speed * remaining_time
		if current_distance <= distance_to_next and current_distance >= 0.0:
			position = start_point.linear_interpolate(
					_path[0], 
					current_distance / distance_to_next
					)
			break
		elif current_distance < 0.0:
			position = _path[0]
			break
		remaining_time -= distance_to_next / current_speed
		start_point = _path[0]
		_path.remove(0)
		_path_weights.remove(0)


func set_path(path: PoolVector2Array, weights: PoolRealArray) -> void:
	_path = path
	_path_weights = weights


# Adjusts path points from the center of the tile to it's border towards next tile
# It forces terrain weight to affect only within the tile
func _move_path_point_to_tile_borders(path: PoolVector2Array) -> PoolVector2Array:
	var new_path = []
	for i in range(1, path.size()):
		new_path.append(path[i - 1].linear_interpolate(path[i], 0.5))
	return PoolVector2Array(new_path)


func _get_path_line_color():
	return Color(0, 0, 1, 1)
