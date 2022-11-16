extends Control


signal settings_saved


func _ready():
	load_settings()


func _on_BtnBack_pressed():
	save_settings()
	emit_signal("settings_saved")


# Graphics settings
func _on_DropdownResolution_item_selected(index):
	SettingsController.set_resolution(index)


func _on_CheckBoxFullscreen_toggled(button_pressed):
	SettingsController.set_fullscreen(button_pressed)


func _on_SliderAnimateSpeed_drag_ended(value_changed):
	if value_changed:
		SettingsController.set_animate_speed(find_node("SliderAnimateSpeed").value)


func _on_CheckBoxRomanNum_toggled(button_pressed):
	SettingsController.set_roman_numerals(button_pressed)


func save_settings():
	var settings_file = File.new()
	var error = settings_file.open("user://settings.json", File.WRITE)
	if error:
		print("Unable to save settings file.")
		return
	
	var settings_data = {
		"resolution":		find_node("DropdownResolution").selected,
		"fullscreen":		find_node("CheckBoxFullscreen").pressed,
		"animate_speed":	find_node("SliderAnimateSpeed").value,
		"roman_numerals":	find_node("CheckBoxRomanNums").pressed,
	}
	settings_file.store_line(to_json(settings_data))


func load_settings():
	find_node("DropdownResolution").selected = SettingsController.graphics_resolution
	find_node("CheckBoxFullscreen").pressed = SettingsController.graphics_fullscreen
	find_node("SliderAnimateSpeed").value = SettingsController.graphics_animate_speed_slider
	find_node("CheckBoxRomanNums").pressed = SettingsController.graphics_roman_numerals
