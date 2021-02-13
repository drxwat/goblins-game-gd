extends Node

var RACES_SCENES = {
	GlobalConstants.RACE.GOBLIN: preload("res://battle/units/goblin/goblin-battle-unit/GoblinBattleUnit.tscn")
}

enum TERRAIN_OBJECTS { FREE, UNIT, OBSTACLE }
