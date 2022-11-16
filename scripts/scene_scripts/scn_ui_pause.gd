extends CanvasLayer


var game_paused setget set_game_paused


func _unhandled_input(event):
	if (
		event.is_action_pressed("ui_pause")
		and get_tree().get_current_scene().get_name().find("ScnUi") != 0
		and $ScnUiSettingsMenu.visible == false
	):
		self.game_paused = !game_paused


func _on_BtnResume_pressed():
	self.game_paused = false


func _on_BtnSettings_pressed():
	$PauseMenu.hide()
	$ScnUiSettingsMenu.show()


func _on_BtnMainMenu_pressed():
	self.game_paused = false
	SceneController.change_scene_fade("res://scenes/scn_ui_main_menu.tscn", 1.0)


func _on_BtnQuit_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	
	
func _on_ScnUiSettingsMenu_settings_saved():
	$ScnUiSettingsMenu.hide()
	$PauseMenu.show()


func set_game_paused(value):
	game_paused = value
	get_tree().paused = game_paused
	visible = game_paused
