extends CanvasLayer

onready var node_tween = $Tween
onready var node_shade = $Shade
onready var node_center_container = $CenterContainer
onready var node_popup_start_battle = $CenterContainer/PopupStartBattle
onready var node_popup_battle_lost = $CenterContainer/PopupBattleLost
onready var node_popup_battle_won = $CenterContainer/PopupBattleWon
onready var node_fade = $Fade


func _on_BtnMenu_pressed():
	SceneController.change_scene_fade("res://scenes/scn_ui_main_menu.tscn", 1.0)


func _on_BtnRetry_pressed():
	SceneController.reload_scene_fade(1.0)


func _on_BtnNext_pressed():
	var next_scene = "res://scenes/scn_ui_main_menu.tscn"
	var progress = SceneController.get_level_progress()
	if progress & (1 << 0) != 0:
		next_scene = "res://scenes/scn_card_battle_henryii.tscn"
	if progress & (1 << 1) != 0:
		next_scene = "res://scenes/scn_card_battle_midas.tscn"
	if progress & (1 << 2) != 0:
		next_scene = "res://scenes/scn_ui_credits.tscn"
	SceneController.change_scene_fade(next_scene, 1.0)


func show_popup(popup):
	match popup:
		"battle_lost":
			node_shade.show()
			node_popup_battle_lost.show()
		"battle_won":
			node_shade.show()
			node_popup_battle_won.show()


func animate_popup(popup):
	match popup:
		"battle_begin":
			node_popup_start_battle.rect_scale = Vector2(0, 0)
			yield(get_tree(), "idle_frame")
			node_popup_start_battle.show()
			node_tween.interpolate_property(
				node_popup_start_battle,
				"rect_scale",
				Vector2(0, 0),
				Vector2(1, 1),
				0.5
			)
			node_tween.start()
			yield(node_tween, "tween_completed")
			yield(get_tree().create_timer(1.0, false), "timeout")
		_:
			yield(get_tree(), "idle_frame")


func hide_popup():
	for child in node_center_container.get_children():
		child.hide()
	node_shade.hide()


func fade_in(color, time):
	var start_color = color
	start_color.a = 0
	node_fade.show()
	node_tween.interpolate_property(node_fade, "color", start_color, color, time)
	node_tween.start()
	yield(node_tween, "tween_completed")


func fade_out(time):
	var end_color = node_fade.color
	end_color.a = 0
	node_tween.interpolate_property(node_fade, "color", node_fade.color, end_color, time)
	node_tween.start()
	yield(node_tween, "tween_completed")
	node_fade.hide()
