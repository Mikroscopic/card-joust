extends Control


func _ready():
	var show_level_select = false
	if SceneController.get_level_progress() & (1 << 0) != 0:
		show_level_select = true
		find_node("BtnLvl1").disabled = false
	if SceneController.get_level_progress() & (1 << 1) != 0:
		show_level_select = true
		find_node("BtnLvl2").disabled = false
	if show_level_select:
		find_node("BtnNewGame").hide()
		find_node("BtnLvlSelect").show()


func _on_BtnNewGame_pressed():
	SceneController.change_scene_fade("res://scenes/scn_card_battle_tutorial.tscn", 1.0)


func _on_BtnLvlSelect_pressed():
	$MainMenu.hide()
	$LevelSelectMenu.show()


func _on_BtnLvlSelectBack_pressed():
	$LevelSelectMenu.hide()
	$MainMenu.show()


func _on_BtnLvl0_pressed():
	SceneController.change_scene_fade("res://scenes/scn_card_battle_tutorial.tscn", 1.0)


func _on_BtnLvl1_pressed():
	SceneController.change_scene_fade("res://scenes/scn_card_battle_henryii.tscn", 1.0)


func _on_BtnLvl2_pressed():
	SceneController.change_scene_fade("res://scenes/scn_card_battle_midas.tscn", 1.0)


func _on_BtnSettings_pressed():
	$MainMenu.hide()
	$ScnUiSettingsMenu.show()


func _on_BtnQuit_pressed():
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)


func _on_ScnUiSettingsMenu_settings_saved():
	$ScnUiSettingsMenu.hide()
	$MainMenu.show()






