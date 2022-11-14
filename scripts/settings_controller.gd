extends Node


var graphics_resolution = 0
var graphics_fullscreen = true
var graphics_animate_speed = 1.0
var graphics_animate_speed_slider = 1.0
var graphics_roman_numerals = true


func _ready():
	load_settings()


func load_settings():
	var settings_file = File.new()
	var error = settings_file.open("user://settings.json", File.READ)
	if error:
		print("Unable to load settings file.")
		return
	
	var settings_data = parse_json(settings_file.get_as_text())
	set_resolution(int(settings_data["resolution"]))
	set_fullscreen(bool(settings_data["fullscreen"]))
	set_animate_speed(float(settings_data["animate_speed"]))
	set_roman_numerals(bool(settings_data["roman_numerals"]))


func set_resolution(v):
	graphics_resolution = v
	var min_size
	match graphics_resolution:
		0:
			min_size = Vector2(1280.0, 720.0)
		1:
			min_size = Vector2(1920.0, 1080.0)
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_VIEWPORT, SceneTree.STRETCH_ASPECT_KEEP, min_size)


func set_fullscreen(v):
	graphics_fullscreen = v
	OS.window_fullscreen = graphics_fullscreen


func set_animate_speed(v):
	graphics_animate_speed_slider = v
	if v < 1:
		graphics_animate_speed = -v + 2
	else:
		graphics_animate_speed = (v - 1) / -2 + 1


func set_roman_numerals(v):
	graphics_roman_numerals = v
