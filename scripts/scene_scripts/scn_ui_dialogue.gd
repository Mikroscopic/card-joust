extends CanvasLayer


signal messages_finished

var active_box setget set_active_box
var messages: Array = [] setget set_messages

func _ready():
	active_box = find_node("DialogueBoxTop")


func _input(event):
	if event.is_action_pressed("ui_dialogue_next") and len(messages) > 0:
		var animation_player = active_box.find_node("AnimationPlayer")
		if animation_player.is_playing():
			animation_player.advance(10.0)
		else:	
			messages.pop_back()
			if len(messages) == 0:
				active_box.hide()
				yield(get_tree(), "idle_frame")
				hide()
				emit_signal("messages_finished")
			else:
				show_message(messages.back())


func set_active_box(value: int):
	var is_visible = active_box.visible
	active_box.hide()
	match value:
		0:
			active_box = find_node("DialogueBoxTop")
		1:
			active_box = find_node("DialogueBoxBottom")
		2:
			active_box = find_node("DialogueBoxMiddleClear")
	if is_visible:
		active_box.show()


func set_messages(value):
	value.invert()
	messages = value
	show()
	show_message(messages.back())


func show_message(message: String):
	active_box.show()
	active_box.find_node("Text").bbcode_text = (
		"[wave amp=20 freq=3]"
		+ message
		+ "[/wave]"
	)
	var animation_player = active_box.find_node("AnimationPlayer")
	animation_player.play("text_write", -1, 1.0 / len(message))
	yield(animation_player, "animation_finished")
