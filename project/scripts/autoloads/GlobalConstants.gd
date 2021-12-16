extends Node

var id_seq := 0 setget , get_new_id

const DEBUG_PATH = false
const DEBUG_CITIES_ROUTES = true

const MOVE_AREAS := 3.0 # Amount of move zones/actions of units


enum RACE { GOBLIN, HUMAN }

enum STATS { ATTACK, DAMAGE, DEFENCE, HIT_POINTS, MOVE_POINTS }

enum WEAPON { NONE, AXE, MACE, SWORD, BOW, SHIELD }

const RACE_META = {
	RACE.GOBLIN: {
		"STATS": {
			STATS.ATTACK: 6.0,
			STATS.DEFENCE: 8.0,
			STATS.DAMAGE: 3.0,
			STATS.HIT_POINTS: 25.0,
			STATS.MOVE_POINTS: 6.0
		}
	},
	RACE.HUMAN: {
		"STATS": {
			STATS.ATTACK: 7.0,
			STATS.DEFENCE: 5.0,
			STATS.DAMAGE: 3.0,
			STATS.HIT_POINTS: 30.0,
			STATS.MOVE_POINTS: 6.0
		}
	}
}

enum EFFECTS {
	CRIT,
	STUN,
	HIT_CHANCE,
}

const WEAPON_META = {
	WEAPON.NONE: {
		"MIN": 0,
		"MAX": 0,
		"EFFECTS": []
	},
	WEAPON.AXE: {
		"MIN": 4,
		"MAX": 9,
		"EFFECTS": [
			[EFFECTS.CRIT, 0.10]
		]
	},
	WEAPON.MACE: {
		"MIN": 5,
		"MAX": 8,
		"EFFECTS": [
			[EFFECTS.STUN, 0.10]
		]
	},
	WEAPON.SWORD: {
		"MIN": 5,
		"MAX": 7,
		"EFFECTS": [
			[EFFECTS.HIT_CHANCE, 0.10]
		]
	},
	WEAPON.BOW: {
		"IS_LEFT_HANDED": true,
		"MIN": 3,
		"MAX": 7,
		"IS_RANGE": true,
		"EFFECTS": [
			[EFFECTS.HIT_CHANCE, -0.10]
		],
		"RANGE_DISTANCE": 3,
	},
}

enum BATTLE_TEAM {
	TEAM1, TEAM2
}

func get_new_id():
	id_seq += 1
	return id_seq


func _init():
	randomize()
