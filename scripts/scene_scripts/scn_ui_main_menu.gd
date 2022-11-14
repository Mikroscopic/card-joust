extends Control


func _on_BtnNewGame_pressed():
	SceneController.change_scene_fade("res://scenes/scn_card_battle.tscn", 1.0)


func _on_BtnSettings_pressed():
	SceneController.change_scene("res://scenes/scn_ui_settings_menu.tscn")


func _on_BtnQuit_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
