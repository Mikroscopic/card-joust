extends Control


signal settings_saved


func _on_ScnUiSettingsMenu_visibility_changed():
	if visible:
		load_settings()


func _on_BtnBack_pressed():
	if not OS.has_feature("HTML5"):
		save_settings()
	emit_signal("settings_saved")


# Graphics settings
func _on_CheckBoxFullscreen_toggled(button_pressed):
	SettingsController.graphics_fullscreen = button_pressed


func _on_SliderAnimateSpeed_value_changed(value):
	SettingsController.graphics_animation_time_slider = value
	

func _on_CheckBoxRomanNum_toggled(button_pressed):
	SettingsController.graphics_roman_numerals = button_pressed


func _on_SliderVolMaster_value_changed(value):
	SettingsController.audio_master_volume = value


func _on_SliderVolSfx_value_changed(value):
	SettingsController.audio_sfx_volume = value


func _on_SliderVolMusic_value_changed(value):
	SettingsController.audio_music_volume = value


func save_settings():
	var settings_file = File.new()
	var error = settings_file.open("user://settings.json", File.WRITE)
	if error:
		print("Unable to save settings file.")
		return
	
	var settings_data = {
		"fullscreen":			find_node("CheckBoxFullscreen").pressed,
		"animation_timescale":	find_node("SliderAnimateSpeed").value,
		"roman_numerals":		find_node("CheckBoxRomanNums").pressed,
		"master_volume":		find_node("SliderVolMaster").value,
		"sfx_volume":			find_node("SliderVolSfx").value,
		"music_volume":			find_node("SliderVolMusic").value,
	}
	settings_file.store_line(to_json(settings_data))


func load_settings():
	if not OS.has_feature("HTML5"):
		find_node("CheckBoxFullscreen").pressed = SettingsController.graphics_fullscreen
	else:
		find_node("CheckBoxFullscreen").pressed = false
		$CenterContainer/TabContainer/Graphics/HBoxContainer2.visible = false
	find_node("SliderAnimateSpeed").value = SettingsController.graphics_animation_time_slider
	find_node("CheckBoxRomanNums").pressed = SettingsController.graphics_roman_numerals
	find_node("SliderVolMaster").value = SettingsController.audio_master_volume
	find_node("SliderVolSfx").value = SettingsController.audio_sfx_volume
	find_node("SliderVolMusic").value = SettingsController.audio_music_volume

