extends Node

const DEBUG_PATH = true
const SCENE_OBJ_PATH = "res://scene_objects/"

const ENEMY_SCENE_PATH = SCENE_OBJ_PATH + "Enemy.tscn"

enum RACE { GOBLIN }

enum STATS { STR, AGI, HP, AP, MP }

enum WEAPON { NONE, AXE, MACE, SWORD, BOW, SHIELD }

const RACE_META = {
	RACE.GOBLIN: {
		"STATS": {
			STATS.STR: 3,
			STATS.AGI: 5,
			STATS.HP: 12,
			STATS.AP: 3,
			STATS.MP: 3,
		}
	}
}

enum BATTLE_TEAM {
	TEAM1, TEAM2
}

