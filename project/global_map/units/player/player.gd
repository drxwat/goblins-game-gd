extends Unit

signal contacted_enemy(player, enemy)

var is_post_battle_timeout = false
var post_battle_timeout = 2 

func _on_ContactArea_area_shape_entered(area_id, area, area_shape, local_shape):
	if not(is_post_battle_timeout):
		if area.name == 'ContactArea':
			if area.owner.name == 'Enemy':
				print(area)
				is_post_battle_timeout = true
				emit_signal("contacted_enemy", self, area)
				get_tree().paused = true
				yield(get_tree().create_timer(post_battle_timeout, false), "timeout")
				is_post_battle_timeout = false
