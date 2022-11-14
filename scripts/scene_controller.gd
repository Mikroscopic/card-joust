extends Node


func _ready():
	pass

func change_scene(path: String):
	print("DEBUG: Loading scene " + path)
	get_tree().change_scene(path)
	ScnUiOverlay.hide_popup()
	ScnUiOverlay.hide()


func change_scene_fade(path: String, time: float):
	ScnUiOverlay.show()
	yield(ScnUiOverlay.fade_in(Color.black, time / 2), "completed")
	print("DEBUG: Loading scene " + path)
	get_tree().change_scene(path)
	ScnUiOverlay.hide_popup()
	yield(ScnUiOverlay.fade_out(time / 2), "completed")
	ScnUiOverlay.hide()


func reload_scene():
	print("DEBUG: reloading scene...")
	get_tree().reload_current_scene()
	ScnUiOverlay.hide_popup()
	ScnUiOverlay.hide()


func reload_scene_fade(time: float):
	ScnUiOverlay.show()
	yield(ScnUiOverlay.fade_in(Color.black, time / 2), "completed")
	print("DEBUG: reloading scene...")
	get_tree().reload_current_scene()
	ScnUiOverlay.hide_popup()
	yield(ScnUiOverlay.fade_out(time / 2), "completed")
	ScnUiOverlay.hide()
