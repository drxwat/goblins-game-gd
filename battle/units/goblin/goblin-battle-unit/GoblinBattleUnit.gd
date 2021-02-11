extends BattleUnit

var axe_scene: PackedScene = preload("res://battle/units/weapon/scene_objects/Axe.tscn")

var weapon_meta = {
	GlobalConstants.WEAPON.AXE: {
		"translation": Vector3(-9.284, 4.313, 11.601),
		"rotation_degrees": Vector3(-48.407, 8.681, -63.369),
		"scale": Vector3(2 ,2 ,2),
		"mesh_scene": axe_scene
	}
}

func _get_weapon_meta():
	return weapon_meta
