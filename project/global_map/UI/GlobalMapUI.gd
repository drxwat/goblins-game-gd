extends Control

onready var PreBattleDialog = $"PreBattleDialog"

func _on_contacted_enemy(player, enemy):
	PreBattleDialog.visible = true


func _on_ButtonExit_pressed():
	PreBattleDialog.visible = false
	get_tree().paused = false
