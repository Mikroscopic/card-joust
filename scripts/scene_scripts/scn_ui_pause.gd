extends CanvasLayer


var game_paused setget set_game_paused

onready var node_pause_menu = $PauseMenu
onready var node_ui_settings_menu = $ScnUiSettingsMenu


func _unhandled_input(event):
	if (
		event.is_action_pressed("ui_pause")
		and get_tree().get_current_scene().get_name().find("ScnUi") != 0
		and node_ui_settings_menu.visible == false
	):
		self.game_paused = !game_paused


func _on_BtnResume_pressed():
	self.game_paused = false


func _on_BtnSettings_pressed():
	node_pause_menu.hide()
	node_ui_settings_menu.show()


func _on_BtnMainMenu_pressed():
	self.game_paused = false
	SceneController.change_scene_fade("res://scenes/scn_ui_main_menu.tscn", 1.0)


func _on_BtnQuit_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
	
	
func _on_ScnUiSettingsMenu_settings_saved():
	node_ui_settings_menu.hide()
	node_pause_menu.show()


func set_game_paused(value):
	game_paused = value
	get_tree().paused = game_paused
	visible = game_paused
