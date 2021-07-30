extends Node

var id_seq := 0 setget , get_new_id

const DEBUG_PATH = true
const SCENE_OBJ_PATH = "res://scene_objects/"

const ENEMY_SCENE_PATH = SCENE_OBJ_PATH + "Enemy.tscn"

enum RACE { GOBLIN }

enum STATS { STR, AGI, STAM, MOVE_POINTS }

enum WEAPON { NONE, AXE, MACE, SWORD, BOW, SHIELD }

const RACE_META = {
	RACE.GOBLIN: {
		"STATS": {
			STATS.STR: 3,
			STATS.AGI: 5,
			STATS.STAM: 12,
			STATS.MOVE_POINTS: 8
		}
	}
}

enum BATTLE_METRICS {
	MELEE_HIT_CHANCE, MELEE_DAMAGE, MELEE_CRIT_CHANCE,
	RANGE_HIT_CHANCE, RANGE_DAMAGE, RANGE_CRIT_CHANCE,
	HEALTH_POINTS, MANA_POINTS,
}

const BATTLE_METRICS_MULTIPLIERS = {
	STATS.STR: {
		BATTLE_METRICS.MELEE_HIT_CHANCE: 0.15,
		BATTLE_METRICS.MELEE_DAMAGE: 0.5,
		BATTLE_METRICS.MELEE_CRIT_CHANCE: 0.1,
		BATTLE_METRICS.RANGE_HIT_CHANCE: 0.1,
		BATTLE_METRICS.RANGE_DAMAGE: 0.2,
		BATTLE_METRICS.HEALTH_POINTS: 0.7,
	},
	STATS.AGI: {
		BATTLE_METRICS.MELEE_HIT_CHANCE: 0.35,
		BATTLE_METRICS.MELEE_DAMAGE: 0.15,
		BATTLE_METRICS.MELEE_CRIT_CHANCE: 0.25,
		BATTLE_METRICS.RANGE_HIT_CHANCE: 0.25,
		BATTLE_METRICS.RANGE_DAMAGE: 0.4,
		BATTLE_METRICS.HEALTH_POINTS: 0.1,
	},
	STATS.STAM: {
		BATTLE_METRICS.MELEE_HIT_CHANCE: 0.1,
		BATTLE_METRICS.MELEE_DAMAGE: 0.2,
		BATTLE_METRICS.RANGE_HIT_CHANCE: 0.1,
		BATTLE_METRICS.HEALTH_POINTS: 8,
	}
}

enum BATTLE_TEAM {
	TEAM1, TEAM2
}

# Battle metrics calculation

func calculate_metrics(stats):
	var battle_metrics = {}
	for stat in stats:
		var metrics = BATTLE_METRICS_MULTIPLIERS[stat]
		for battle_metric in metrics:
			battle_metrics[battle_metric] = battle_metrics[battle_metric] + metrics.get(battle_metric, 0.0)
	return battle_metrics

func get_new_id():
	id_seq += 1
	return id_seq
