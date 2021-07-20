extends BattleUnit

var axe_scene: PackedScene = preload("res://battle/units/weapon/scene_objects/Axe.tscn")
var mace_scene: PackedScene = preload("res://battle/units/weapon/scene_objects/Mace.tscn")
var portrait: Texture = preload("res://battle/units/goblin/portrait.png")

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
	}
}

func get_portrait() -> Texture:
	return portrait

func _get_weapon_meta():
	return weapon_meta
