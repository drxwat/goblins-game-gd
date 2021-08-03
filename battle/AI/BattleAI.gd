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
		var unit = team2[unit_id]
		if unit.is_dead or unit.move_points <= 0:
			continue
		turn_team.push_back(unit)
	make_next_unit_turn()
	
func make_next_unit_turn():
	var has_enemies = false
	for unit_id in team1:
		if not team1[unit_id].is_dead:
			has_enemies = true
			break
	if turn_team.size() > 0 and has_enemies:
		var unit = turn_team.pop_front()
		act_unit(unit)
	else:
		turn_team.clear()
		emit_signal("ai_turn_end")

func act_unit(unit: BattleUnit):
	var enemy_search_restult = find_ememy(unit)
	var enemy = enemy_search_restult[0]
	var is_attack = enemy_search_restult[1]
	terrain.free_point_from_unit(enemy.global_transform.origin)
	var path = terrain.get_map_path(unit.global_transform.origin, enemy.global_transform.origin)
	terrain.occupy_point_with_unit(enemy.global_transform.origin, enemy.battle_id)
	if path.size() > 1:
		terrain.free_point_from_unit(unit.global_transform.origin)
		terrain.unregister_unit(unit.global_transform.origin)
		unit.connect("on_move_end", self, "_handle_unit_move_end", [unit, enemy, is_attack])
		path.remove(0)
		path.resize(path.size() - 1)
		unit.set_path(path)
	else:
		attack_enemy(unit, enemy)

func _handle_unit_attack_end(unit: BattleUnit, enemy: BattleUnit):
	unit.disconnect("on_attack_end", self, "_handle_unit_attack_end")
	make_next_unit_turn()

func _handle_unit_move_end(unit: BattleUnit, enemy: BattleUnit, is_attack: bool = false):
	unit.disconnect("on_move_end", self, "_handle_unit_move_end")
	terrain.occupy_point_with_unit(unit.global_transform.origin, unit.battle_id)
	terrain.register_unit(unit.global_transform.origin, unit.battle_id)
	if is_attack:
		attack_enemy(unit, enemy)
	else:
		make_next_unit_turn()

func attack_enemy(unit: BattleUnit, enemy: BattleUnit):
	unit.connect("on_attack_end", self, "_handle_unit_attack_end", [unit, enemy])
	unit.mele_attack(enemy)

func find_ememy(unit: BattleUnit):
	var enemies = []
	for unit_id in team1:
		var enemy = team1[unit_id]
		if enemy.is_dead:
			continue
		terrain.free_point_from_unit(enemy.global_transform.origin)
		var path = terrain.get_map_path(unit.global_transform.origin, enemy.global_transform.origin)
		terrain.occupy_point_with_unit(enemy.global_transform.origin, enemy.battle_id)
		enemies.push_back([path.size() - 2, enemy])
	enemies.sort_custom(MetaUnitTuppleSorter, "sort_ascending")
	var close_enemies = []
	for enemy_meta in enemies:
		if unit.move_points >= enemy_meta[0]:
			close_enemies.push_back(enemy_meta)
	if close_enemies.size() == 0:
		return [enemies[0][1], false] # Go towards the closest enemy
	var potential_victims = []
	for potential_victim in close_enemies:
		potential_victims.push_back([potential_victim[1].hp, potential_victim[1]])
	potential_victims.sort_custom(MetaUnitTuppleSorter, "sort_ascending")
	return [potential_victims[0][1], true] # Go next to the closest enemy with lowest HP

class MetaUnitTuppleSorter:
	static func sort_ascending(a, b):
		if a[0] < b[0]:
			return true
		return false
