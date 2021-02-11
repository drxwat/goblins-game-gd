extends Spatial

const GRID_STEP := Vector3(2, 0, 0)

var team1_units := []
var team2_units := []

func _ready():
	var units = get_children()

func initialize_battle(team1: Array, team2: Array, spawn_point_1: Vector3, spawn_point_2: Vector3):
	var unit_position = spawn_point_1
	for unit_meta in team1:
		var unit_scene = BattleConstants.RACES_SCENES[unit_meta["RACE"]]
		var unit = unit_scene.instance()
		unit.right_hand = unit_meta["WEAPON"]
		unit.translation = unit_position
		unit.rotation = Vector3(0, -180, 0)
		team1_units.append(unit)
		self.add_child(unit)
		unit_position += GRID_STEP
	
	unit_position = spawn_point_2
	for unit_meta in team2:
		var unit_scene = BattleConstants.RACES_SCENES[unit_meta["RACE"]]
		var unit = unit_scene.instance()
		unit.right_hand = unit_meta["WEAPON"]
		unit.translation = unit_position
		team2_units.append(unit)
		self.add_child(unit)
		unit_position += GRID_STEP

