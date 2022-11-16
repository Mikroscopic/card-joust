extends Control


func _on_BtnNewGame_pressed():
	SceneController.change_scene_fade("res://scenes/scn_card_battle.tscn", 1.0)


func _on_BtnSettings_pressed():
	$MainMenu.hide()
	$ScnUiSettingsMenu.show()


func _on_BtnQuit_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_ScnUiSettingsMenu_settings_saved():
	$ScnUiSettingsMenu.hide()
	$MainMenu.show()
