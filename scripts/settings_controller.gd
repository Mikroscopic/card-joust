extends Node


var graphics_fullscreen = true setget set_graphics_fullscreen
var graphics_animation_timescale = 1.0
var graphics_animation_time_slider = 1.0 setget set_graphics_animation_time_slider
var graphics_roman_numerals = true setget set_graphics_roman_numerals
var audio_master_volume = 1.0 setget set_audio_master_volume
var audio_sfx_volume = 1.0 setget set_audio_sfx_volume
var audio_music_volume = 1.0 setget set_audio_music_volume



func _ready():
	var cursor_img_arrow = load("res://assets/sprites/cursor_arrow.png")
	var cursor_img_hand = load("res://assets/sprites/cursor_hand.png")
	Input.set_custom_mouse_cursor(cursor_img_arrow, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(cursor_img_hand, Input.CURSOR_POINTING_HAND, Vector2(10.0, 2.0))
	if not OS.has_feature("HTML5"):
		load_settings()


func load_settings():
	var settings_file = File.new()
	var error = settings_file.open("user://settings.json", File.READ)
	if error:
		print("Unable to load settings file.")
		return
	
	var settings_data = parse_json(settings_file.get_as_text())
	self.graphics_fullscreen = bool(settings_data["fullscreen"])
	self.graphics_animation_time_slider = float(settings_data["animation_timescale"])
	self.graphics_roman_numerals = bool(settings_data["roman_numerals"])
	self.audio_master_volume = float(settings_data["master_volume"])
	self.audio_sfx_volume = float(settings_data["sfx_volume"])
	self.audio_music_volume = float(settings_data["music_volume"])


func set_graphics_fullscreen(v):
	graphics_fullscreen = v
	OS.window_fullscreen = graphics_fullscreen


func set_graphics_animation_time_slider(v):
	graphics_animation_time_slider = v
	if v < 1:
		# 50% - 100%
		graphics_animation_timescale = v / 2 + 0.5
	else:
		# 100% - 200%
		graphics_animation_timescale = v


func set_graphics_roman_numerals(v):
	graphics_roman_numerals = v
	for card in get_tree().get_nodes_in_group("has_numerals"):
		card.update_numerals()


func set_audio_master_volume(v):
	audio_master_volume = v
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear2db(audio_master_volume)
	)


func set_audio_sfx_volume(v):
	audio_sfx_volume = v
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Sfx"),
		linear2db(audio_sfx_volume)
	)


func set_audio_music_volume(v):
	audio_music_volume = v
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear2db(audio_music_volume)
	)
