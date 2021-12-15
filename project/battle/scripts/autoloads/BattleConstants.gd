extends Node

var RACES_SCENES = {
	GlobalConstants.RACE.GOBLIN: preload("res://battle/units/goblin/goblin-battle-unit/GoblinBattleUnit.tscn"),
	GlobalConstants.RACE.HUMAN: preload("res://battle/units/peasant-1/peasant-1-battle-unit/Peasant1BattleUnit.tscn")
}

enum TERRAIN_OBJECTS { FREE, UNIT, OBSTACLE }
