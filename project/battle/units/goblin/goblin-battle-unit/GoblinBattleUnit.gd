extends BattleUnit

var axe_scene: PackedScene = preload("res://battle/units/weapon/scene_objects/Axe.tscn")
var mace_scene: PackedScene = preload("res://battle/units/weapon/scene_objects/Mace.tscn")
var bow_scene: PackedScene = preload("res://battle/units/weapon/scene_objects/Bow.tscn")

var weapon_meta = {
	GlobalConstants.WEAPON.AXE: {
		"translation": Vector3(-9.284, 4.313, 11.601),
		"rotation_degrees": Vector3(-48.407, 8.681, -63.369),
		"scale": Vector3(2 ,2 ,2),
		"mesh_scene": axe_scene
	},
	GlobalConstants.WEAPON.MACE: {
		"translation": Vector3(-4.216, 10.441, 2.72),
		"rotation_degrees": Vector3(7.509, -12.318, -74.767),
		"scale": Vector3(2 ,2 ,2),
		"mesh_scene": mace_scene
	},
	GlobalConstants.WEAPON.BOW: {
		"translation": Vector3(-57.278, 8.035, 3.012),
		"rotation_degrees": Vector3(-72.21, 34.003, -120.812),
		"scale": Vector3(2.5 ,2.5 ,2.5),
		"mesh_scene": bow_scene
	}
}

func _get_weapon_meta():
	return weapon_meta
