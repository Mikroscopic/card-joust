extends CanvasLayer


func _on_BtnMenu_pressed():
	SceneController.change_scene_fade("res://scenes/scn_ui_main_menu.tscn", 1.0)


func _on_BtnRetry_pressed():
	SceneController.reload_scene_fade(1.0)


func _on_BtnNext_pressed():
	SceneController.change_scene_fade("res://scenes/scn_ui_main_menu.tscn", 1.0)


func show_popup(popup):
	match popup:
		"battle_lost":
			$Shade.show()
			$CenterContainer/PopupBattleLost.show()
		"battle_won":
			$Shade.show()
			$CenterContainer/PopupBattleWon.show()


func animate_popup(popup):
	match popup:
		"battle_begin":
			$CenterContainer/PopupStartBattle.rect_scale = Vector2(0, 0)
			yield(get_tree(), "idle_frame")
			$CenterContainer/PopupStartBattle.show()
			$Tween.interpolate_property(
				$CenterContainer/PopupStartBattle,
				"rect_scale",
				Vector2(0, 0),
				Vector2(1, 1),
				0.5
			)
			$Tween.start()
			yield($Tween, "tween_completed")
			yield(get_tree().create_timer(1.0), "timeout")
		_:
			yield(get_tree(), "idle_frame")


func hide_popup():
	for child in $CenterContainer.get_children():
		child.hide()
	$Shade.hide()


func fade_in(color, time):
	var start_color = color
	start_color.a = 0
	$Fade.show()
	$Tween.interpolate_property($Fade, "color", start_color, color, time)
	$Tween.start()
	yield($Tween, "tween_completed")


func fade_out(time):
	var end_color = $Fade.color
	end_color.a = 0
	$Tween.interpolate_property($Fade, "color", $Fade.color, end_color, time)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Fade.hide()
