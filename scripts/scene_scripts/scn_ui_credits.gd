extends Control


func _on_BtnBack_pressed():
	SceneController.change_scene_fade("res://scenes/scn_ui_main_menu.tscn", 1.0)
