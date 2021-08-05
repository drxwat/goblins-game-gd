extends Reference
class_name GlobalUnit

var id: int
var race: int
var weapon: int
var firstname = ""

var unit_stats: Dictionary
var unit_const_stats: Dictionary

func _init(_race: int, _weapon: int, _stats: Dictionary):
	id = GlobalConstants.get_new_id()
	race = _race
	weapon = _weapon
	var race_stats = GlobalConstants.RACE_META[race]["STATS"]
	unit_stats = _stats.duplicate()
	for stat_key in race_stats:
		unit_stats[stat_key] = unit_stats.get(stat_key, 0.0) + race_stats[stat_key]
	unit_const_stats = unit_stats.duplicate()
	firstname = NameGenerator.get_name(race)

func get_battle_metrics():
	return GlobalConstants.calculate_metrics(unit_stats)

func get_stat_value(stat: int):
	return unit_stats[stat]
	
func set_stat_value(stat: int, value):
	unit_stats[stat] = value

func get_max_hp():
	return unit_const_stats.get(GlobalConstants.STATS.HIT_POINTS)

func get_hp():
	return get_stat_value(GlobalConstants.STATS.HIT_POINTS)
	
func set_hp(value: int):
	set_stat_value(GlobalConstants.STATS.HIT_POINTS, value)
	
func get_attack():
	return get_stat_value(GlobalConstants.STATS.ATTACK)
	
func get_defence():
	return get_stat_value(GlobalConstants.STATS.DEFENCE)

func get_wapon_meta():
	return GlobalConstants.WEAPON_META[weapon]
	
func get_damage_range():
	var base_dmg = get_stat_value(GlobalConstants.STATS.DAMAGE)
	var min_dmg = GlobalConstants.WEAPON_META[weapon]["MIN"]
	var max_dmg = GlobalConstants.WEAPON_META[weapon]["MAX"]
	return [base_dmg + min_dmg, base_dmg + max_dmg]
	
func get_max_move_points():
	return get_stat_value(GlobalConstants.STATS.MOVE_POINTS)
