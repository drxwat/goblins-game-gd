extends Troop

signal contacted_enemy(player, enemy)

onready var gfx := $GFX

func _on_ContactArea_area_shape_entered(area_id, area, area_shape, local_shape):
	if area:
		if is_instance_valid(area):
			var enemy = area.owner
			if not(enemy.is_post_battle_timeout):
				if area.name == 'ContactArea':
					enemy.is_post_battle_timeout = true
					emit_signal("contacted_enemy", self, enemy)
					get_tree().paused = true
					yield(get_tree().create_timer(enemy.post_battle_timeout, false), "timeout")
					enemy.is_post_battle_timeout = false


func _on_process(delta: float):
	._on_process(delta)
	if is_moving():
		_play_move_animation(position.direction_to(_path[0]))


func _play_move_animation(direction: Vector2):
	gfx.play("walk_down" if direction.y > 0 else "walk_up")
	gfx.flip_h = true if direction.x > 0 else false
