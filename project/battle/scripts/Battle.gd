extends Spatial

const RAY_LENGTH = 1000
const MOUSE_HOVER_Y_OFFSET = Vector3(0, 0.05, 0)
const MOVE_AREAS := 3.0

const path_dot_scene = preload("res://battle/terrain/path_dot/PathDot.tscn")

onready var camera := $Camera
onready var terrain := $Terrain
onready var mouse_hover := $MouseHover
onready var trace_path := $TracePath
onready var battleUI: = $BattleUI
onready var battleAI: = BattleAI.new()


var team1_units_meta = [
	GlobalUnit.new(GlobalConstants.RACE.GOBLIN, GlobalConstants.WEAPON.AXE, {}),
	GlobalUnit.new(GlobalConstants.RACE.GOBLIN, GlobalConstants.WEAPON.MACE, {}),
	GlobalUnit.new(GlobalConstants.RACE.GOBLIN, GlobalConstants.WEAPON.AXE, {})
]

var team1_spawn_point = Vector3(1, 0, 19)

var team2_units_meta = [
	GlobalUnit.new(GlobalConstants.RACE.GOBLIN, GlobalConstants.WEAPON.AXE, {}),
	GlobalUnit.new(GlobalConstants.RACE.GOBLIN, GlobalConstants.WEAPON.MACE, {}),
	GlobalUnit.new(GlobalConstants.RACE.GOBLIN, GlobalConstants.WEAPON.AXE, {})
]
var team2_spawn_point = Vector3(1, 0, 1)

var team1 := {}
var team2 := {}
var selected_unit = null
var is_action_in_progress := false

var current_hover_cell = Vector3.ZERO
var trace_path_points := []
var hovered_enemy: BattleUnit = null

var turn_number := 1

# Called when the node enters the scene tree for the first time.
func _ready():
	terrain.set_obstacles($Forest)
	if !terrain.is_point_walkable(team1_spawn_point):
		push_error("Team1 spawn point %s is not walkable" % team1_spawn_point)
	if !terrain.is_point_walkable(team2_spawn_point):
		push_error("Team2 spawn point %s is not walkable" % team2_spawn_point)
	team1 = _init_team(team1_units_meta, team1_spawn_point)
	team2 = _init_team(team2_units_meta, team2_spawn_point, true)
	battleAI.initAI(team1, team2, terrain)
	battleAI.connect("ai_turn_end", self, "start_next_turn")
	
	var units = []
	for unit_id in team1:
		units.push_back(team1[unit_id])
	battleUI.set_team_units(units)
	battleUI.connect("focus_unit", self, "on_focus_unit")

func on_focus_unit(unit: BattleUnit):
	unit_focus(unit)

# Creates and spawns units of the team
func _init_team(units_meta: Array, initial_spawn_point: Vector3, enemy = false) -> Dictionary:
	var team := {}
	var spawn_point = initial_spawn_point
	for global_unit in units_meta:
		if spawn_point == null:
			push_error("Team can't be spawned. Stoped at unit %s" % global_unit.id)
			break
#		var unit_meta = units_meta.get(unit_id)
#		var team_unit_meta = unit_meta.duplicate()
		var unit = _produce_unit(global_unit)
		_spawn_unit(unit.id, unit, $Units, spawn_point, PI if not enemy else 0)
		team[unit.id] = unit
		spawn_point = terrain.get_neighbor_walkable_point(spawn_point)
	return team

#
# Turn Managment
#

func end_turn():
	if selected_unit:
		_deselect_unit(selected_unit)
	is_action_in_progress = true
	ai_turn()

func ai_turn():
	battleAI.start_turn()

func start_next_turn():
	is_action_in_progress = false
	turn_number += 1 # TODO: display turn number
	for unit_id in team1:
		team1[unit_id].next_turn_update()
		battleUI.update_unit_info(team1[unit_id])
	for unit_id in team2:
		team2[unit_id].next_turn_update()
	battleUI.enable_next_turn_button()

#
# MOUSE INPUT
#

func _input(event: InputEvent):
	if is_action_in_progress:
		return true
	_handle_left_mouse_click(event)
	_handle_right_mouse_click(event)
	_handle_mouse_move(event)
	_handle_keyboard(event)

func _handle_keyboard(event: InputEvent):
	if not event is InputEventKey:
		return
	if not event.pressed:
		return
	if event.scancode == KEY_TAB:
		_select_next_unit()

func _select_next_unit():
	if selected_unit == null:
		_select_unit(team1.values()[0])
	else:
		var val_team = team1.values()
		var selected_index = val_team.find(selected_unit)
		var next_index = (selected_index + 1) % val_team.size()
		_deselect_unit(selected_unit)
		_select_unit(val_team[next_index])

	unit_focus(selected_unit)

func unit_focus(unit: BattleUnit):
	var target3d = unit.global_transform.origin
	var target2d = Vector2(target3d.x, target3d.z)
	camera.focus_to(target2d)
	
func _handle_left_mouse_click(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_LEFT or not event.pressed:
		return
	var m_position = _get_mouse_projected_position(event.position)
	if !m_position:
		return
	var hover_obj = terrain.get_terrain_object(m_position)
	if hover_obj["TYPE"] != BattleConstants.TERRAIN_OBJECTS.UNIT and selected_unit:
		_deselect_unit(selected_unit)
		return
	if not _is_ally(hover_obj["ID"]):
		return
	if hover_obj["TYPE"] == BattleConstants.TERRAIN_OBJECTS.UNIT:
		var unit_meta = _get_unit_meta_by_id(hover_obj["ID"])
		if !selected_unit:
			_select_unit(unit_meta)
		elif selected_unit != unit_meta:
			_deselect_unit(selected_unit)
			_select_unit(unit_meta)

func _handle_right_mouse_click(event: InputEvent):
	if not event is InputEventMouseButton:
		return
	if event.button_index != BUTTON_RIGHT or not event.pressed:
		return
	var m_position = _get_mouse_projected_position(event.position)
	if m_position and selected_unit:
		_move_and_attack_unit(selected_unit, m_position)

func _handle_mouse_move(event: InputEvent):
	if not event is InputEventMouseMotion:
		return
	var m_position = _get_mouse_projected_position(event.position)
	if m_position:
		var hover_cell = terrain.get_map_cell_center(m_position)
		if hover_cell == current_hover_cell:
			return
		var hover_obj = terrain.get_terrain_object(m_position)
		if hover_obj["TYPE"] == BattleConstants.TERRAIN_OBJECTS.UNIT and not _is_ally(hover_obj["ID"]):
			var unit_meta = _get_unit_meta_by_id(hover_obj["ID"])
			var unit = unit_meta
			if unit != hovered_enemy:
#				battleUI.display_enemy_info(unit)
				_occupy_enemy_unit_point()
			_free_enemy_unit_point(unit)
		elif hovered_enemy and not hovered_enemy.is_dead:
			_occupy_enemy_unit_point()
#			battleUI.hide_enemy_info()
		current_hover_cell = hover_cell
		_move_mouse_hover(m_position)
		_color_mouse_hover(m_position)
		if selected_unit != null:
			_draw_trace_path(selected_unit, selected_unit.global_transform.origin, m_position)

func _draw_trace_path(unit: BattleUnit, from: Vector3, to: Vector3):
	_clear_trace_path()
	var path_points = terrain.get_map_path(from, to)
	path_points.remove(0)

	var i = 0
	for point in path_points:
		var dot = path_dot_scene.instance()
		dot.set_path_color(_get_current_trace_path_color(unit, unit.max_move_points - unit.move_points + i + 1))
		dot.translation = point
		trace_path.add_child(dot)
		trace_path_points.append(weakref(dot))
		i += 1

func _get_current_trace_path_color(unit: BattleUnit, spend_points):
	var area_points = unit.max_move_points / MOVE_AREAS
	if spend_points > unit.max_move_points:
		return PathDot.PathDotColor.WHITE
	
	if spend_points <= area_points:
		return PathDot.PathDotColor.GREEN
	elif spend_points <= area_points * 2:
		return PathDot.PathDotColor.YELLOW
	else:
		return PathDot.PathDotColor.RED
		

func _clear_trace_path():
	for path_point in trace_path_points:
		var path_point_ref = path_point.get_ref()
		if path_point_ref:
			path_point_ref.queue_free()
	trace_path_points.clear()

func _move_mouse_hover(pos: Vector3):
	mouse_hover.translation = terrain.get_map_cell_center(pos) + MOUSE_HOVER_Y_OFFSET

func _free_enemy_unit_point(unit: BattleUnit):
	hovered_enemy = unit
	terrain.free_point_from_unit(unit.global_transform.origin)

func _occupy_enemy_unit_point():
	if hovered_enemy:
		terrain.occupy_point_with_unit(hovered_enemy.global_transform.origin, hovered_enemy.id)
		hovered_enemy = null

func _color_mouse_hover(pos: Vector3):
	var hover_obj = terrain.get_terrain_object(pos)
	match hover_obj["TYPE"]:
		BattleConstants.TERRAIN_OBJECTS.FREE:
			mouse_hover.hover_neutral()
		BattleConstants.TERRAIN_OBJECTS.OBSTACLE:
			mouse_hover.hover_obstacle()
		BattleConstants.TERRAIN_OBJECTS.UNIT:
			if _is_ally(hover_obj["ID"]):
				mouse_hover.hover_ally()
			else:
				mouse_hover.hover_enemy()

func _get_mouse_projected_position(screen_position: Vector2):
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * RAY_LENGTH
	var space_state = camera.get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [], 1)
	
	if not result:
		return null
	return result.position

#
# UNIT API
#

func _select_unit(unit: BattleUnit):
	terrain.free_point_from_unit(unit.global_transform.origin)
	selected_unit = unit
	unit.set_selected(true)
	
func _deselect_unit(unit: BattleUnit):
	terrain.occupy_point_with_unit(unit.global_transform.origin, unit.id)
	selected_unit = null
	unit.set_selected(false)
	_clear_trace_path()

func _move_and_attack_unit(unit: BattleUnit, pos: Vector3):
	if unit.move_points <= 0:
		return
	var path = terrain.get_map_path(unit.global_transform.origin, pos)
	if hovered_enemy:
		path.resize(path.size() - 1)
	if path.size() > 1:
		is_action_in_progress = true
		path.remove(0)
		unit.set_path(path)
		terrain.free_point_from_unit(unit.global_transform.origin)
		terrain.unregister_unit(unit.global_transform.origin)
	elif hovered_enemy:
		unit.mele_attack(hovered_enemy)

func _produce_unit(global_unit: GlobalUnit) -> BattleUnit:
	var unit_scene = BattleConstants.RACES_SCENES[global_unit.race]
	var unit = unit_scene.instance()
	unit.global_unit = global_unit
	unit.right_hand = global_unit.weapon # TODO: Initialize weapon inside BattleUnit
	return unit

func _spawn_unit(unit_id: int, unit: BattleUnit, parent_node: Node, pos: Vector3, rot: float):
	unit.translation = pos
	unit.rotate_y(rot)
	parent_node.add_child(unit)
	unit.connect("on_move_end", self, "_handle_unit_move_end", [unit_id])
	unit.connect("on_dead", self, "_handle_unit_death", [unit_id])
	unit.connect("on_move_step", self, "_update_unit_ui_info", [unit_id])
	unit.connect("on_attack_end", self, "_handle_unit_attack_end", [unit_id])
	unit.connect("on_take_damage_end", self, "_update_unit_ui_info", [unit_id])
	terrain.register_unit(pos, unit_id)
	terrain.occupy_point_with_unit(pos, unit_id)

func _is_ally(id: int):
	return team1.has(id)

func _get_unit_meta_by_id(id: int):
	if _is_ally(id):
		return team1.get(id)
	return team2.get(id, null)
	
func _handle_unit_move_end(unit_id: int):
	var unit = _get_unit_meta_by_id(unit_id)
	terrain.register_unit(unit.global_transform.origin, unit.id)
	if hovered_enemy:
		var path = terrain.get_map_path(unit.global_transform.origin, hovered_enemy.global_transform.origin)
		if path.size() <= 2:
			unit.mele_attack(hovered_enemy)
			return
	is_action_in_progress = false

func _handle_unit_attack_end(unit_id: int):
	is_action_in_progress = false

func _handle_unit_death(unit_id: int):
	var unit = _get_unit_meta_by_id(unit_id)
	var point = unit.global_transform.origin
	terrain.unregister_unit(point)
	terrain.free_point_from_unit(point)
	if _is_ally(unit_id):
		battleUI.remove_unit_avatar(unit)
	if hovered_enemy == unit:
		hovered_enemy = null


func _update_unit_ui_info(unit_id: int):
	var unit = _get_unit_meta_by_id(unit_id)
	if _is_ally(unit_id):
		battleUI.update_unit_info(unit)

