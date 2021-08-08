extends Unit

signal contacted_enemy(enemy)

func _on_ContactArea_area_shape_entered(area_id, area, area_shape, local_shape):
	if area.name == 'ContactArea':
		if area.owner.name == 'Enemy':
			print(area)
			emit_signal("contacted_enemy", area)
			get_tree().paused = true
			yield(get_tree().create_timer(2, false), "timeout")
