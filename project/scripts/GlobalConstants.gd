extends Node

var id_seq := 0 setget , get_new_id

const DEBUG_PATH = true
const SCENE_OBJ_PATH = "res://scene_objects/"

const ENEMY_SCENE_PATH = SCENE_OBJ_PATH + "Enemy.tscn"

enum RACE { GOBLIN }

enum STATS { ATTACK, DAMAGE, DEFENCE, HIT_POINTS, MOVE_POINTS }

enum WEAPON { NONE, AXE, MACE, SWORD, BOW, SHIELD }

const RACE_META = {
	RACE.GOBLIN: {
		"STATS": {
			STATS.ATTACK: 6,
			STATS.DAMAGE: 5,
			STATS.DAMAGE: 5,
			STATS.HIT_POINTS: 15,
			STATS.MOVE_POINTS: 6
		}
	}
}

enum BATTLE_TEAM {
	TEAM1, TEAM2
}

func get_new_id():
	id_seq += 1
	return id_seq


func _init():
	randomize()
