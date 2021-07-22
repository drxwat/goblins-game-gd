extends Reference
class_name BattleAI

signal ai_turn_end

var team1: Dictionary
var team2: Dictionary
var terrain: TerrainGridMap

var turn_team = []

func initAI(_team1: Dictionary, _team2: Dictionary, _terrain: TerrainGridMap):
	team1 = _team1
	team2 = _team2
	terrain = _terrain

func start_turn():
	for unit_id in team2:
		var unit = team2[unit_id]["UNIT"]
		if unit.is_dead:
			continue
		turn_team.push_back(unit)
	make_next_unit_turn()
	
func make_next_unit_turn():
	if turn_team.size() > 0:
		var unit = turn_team.pop_front()
		act_unit(unit)
	else:
		emit_signal("ai_turn_end")

func act_unit(unit: BattleUnit):
	var enemy = find_ememy(unit)
	terrain.free_point_from_unit(enemy.global_transform.origin)
	var path = terrain.get_map_path(unit.global_transform.origin, enemy.global_transform.origin)
	terrain.occupy_point_with_unit(enemy.global_transform.origin, enemy.battle_id)
	if path.size() > 1:
		unit.connect("on_move_end", self, "_handle_unit_move_end", [unit, enemy])
		path.remove(0)
		path.resize(path.size() - 1)
		unit.set_path(path)

func _handle_unit_move_end(unit: BattleUnit, enemy: BattleUnit):
	unit.disconnect("on_move_end", self, "_handle_unit_move_end")
	print("attack!")
	make_next_unit_turn()

func find_ememy(unit: BattleUnit):
	var enemies = []
	for unit_id in team1:
		var enemy = team1[unit_id]["UNIT"]
		if enemy.is_dead:
			continue
		terrain.free_point_from_unit(enemy.global_transform.origin)
		var path = terrain.get_map_path(unit.global_transform.origin, enemy.global_transform.origin)
		terrain.occupy_point_with_unit(enemy.global_transform.origin, enemy.battle_id)
		enemies.push_back([path.size() - 2, enemy])
	enemies.sort_custom(MetaUnitTuppleSorter, "sort_ascending")
	var close_enemies = []
	for enemy_meta in close_enemies:
		if unit.move_points >= enemy_meta[0]:
			close_enemies.push_back(enemy_meta)
	if close_enemies.size() == 0:
		return enemies[0][1]
	var potention_victims = []
	for potention_victim in close_enemies:
		potention_victims.push_back([potention_victim.hp, potention_victim])
	potention_victims.sort_custom(MetaUnitTuppleSorter, "sort_ascending")
	return potention_victims[0][1]

class MetaUnitTuppleSorter:
	static func sort_ascending(a, b):
		if a[0] < b[0]:
			return true
		return false
