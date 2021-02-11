extends BattleUnit

var axe_scene: PackedScene = preload("res://battle/units/weapon/scene_objects/Axe.tscn")

var weapon_meta = {
	BattleConstants.WEAPON.AXE: {
		"translation": Vector3(-9.284, 4.313, 11.601),
		"rotation_degrees": Vector3(-48.407, 8.681, -63.369),
		"scale": Vector3(2 ,2 ,2),
		"mesh_scene": axe_scene
	}
}

export(BattleConstants.WEAPON) var right_hand
export (BattleConstants.WEAPON) var left_hand
export (BattleConstants.BATTLE_TEAM) var team

func _ready():
	pass
	if weapon_meta.has(right_hand):
		var w_meta = weapon_meta.get(right_hand)
		var w_mesh = w_meta.mesh_scene.instance()
		w_mesh.scale = w_meta.scale
		w_mesh.translation = w_meta.translation
		w_mesh.rotation_degrees = w_meta.rotation_degrees
		$Gfx/Armature/Skeleton/RightHandAttachment.add_child(w_mesh)

