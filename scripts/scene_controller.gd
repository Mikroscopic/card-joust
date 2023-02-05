extends Node


var _level_progress = 0


func _ready():
	if not OS.has_feature("HTML5"):
		load_level_progress()

func change_scene(path: String):
	get_tree().change_scene(path)
	ScnUiOverlay.hide_popup()
	ScnUiOverlay.hide()


func change_scene_fade(path: String, time: float):
	ScnUiOverlay.show()
	yield(ScnUiOverlay.fade_in(Color.black, time / 2), "completed")
	get_tree().change_scene(path)
	ScnUiOverlay.hide_popup()
	yield(ScnUiOverlay.fade_out(time / 2), "completed")
	ScnUiOverlay.hide()


func reload_scene():
	get_tree().reload_current_scene()
	ScnUiOverlay.hide_popup()
	ScnUiOverlay.hide()


func reload_scene_fade(time: float):
	ScnUiOverlay.show()
	yield(ScnUiOverlay.fade_in(Color.black, time / 2), "completed")
	get_tree().reload_current_scene()
	ScnUiOverlay.hide_popup()
	yield(ScnUiOverlay.fade_out(time / 2), "completed")
	ScnUiOverlay.hide()


func set_level_completed(level):
	_level_progress = _level_progress | (1 << level)
	if not OS.has_feature("HTML5"):
		save_level_progress()


func get_level_progress():
	return _level_progress


func save_level_progress():
	var save_file = File.new()
	var error = save_file.open("user://save.json", File.WRITE)
	if error:
		print("Unable to save save file.")
		return
	
	var save_data = {
		"level_progress": _level_progress,
	}
	save_file.store_line(to_json(save_data))


func load_level_progress():
	var save_file = File.new()
	var error = save_file.open("user://save.json", File.READ)
	if error:
		print("Unable to load save file.")
		return
	
	var save_data = parse_json(save_file.get_as_text())
	_level_progress = int(save_data["level_progress"])
