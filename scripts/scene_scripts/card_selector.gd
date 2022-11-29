extends Area2D
# Detects when the mouse is hovering over a card.
# Finds the topmost card when cards overlap.


signal card_selected(card)
signal none_selected

var _selected


func _process(delta):
	position = get_global_mouse_position()
	
	var overlaps = get_overlapping_bodies()
	match len(overlaps):
		0:
			if _selected:
				if is_instance_valid(_selected):
					_selected.deselect()
				_selected = null
				emit_signal("none_selected")
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		1:
			if overlaps[0].is_in_group("cards"):
				if _selected != overlaps[0]:
					if _selected:
						if is_instance_valid(_selected):
							_selected.deselect()
					overlaps[0].select()
					_selected = overlaps[0]
					emit_signal("card_selected", _selected)
					Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			else:
				if _selected:
					if is_instance_valid(_selected):
						_selected.deselect()
					_selected = null
					emit_signal("none_selected")
					Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		_:
			var top_index = -1
			var top_item = null
			for o in overlaps:
				if o.is_in_group("cards") and o.z_index > top_index:
					top_index = o.z_index
					top_item = o
			if top_item:
				if _selected != top_item:
					if _selected:
						if is_instance_valid(_selected):
							_selected.deselect()
					overlaps[0].select()
					_selected = overlaps[0]
					emit_signal("card_selected", _selected)
					Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
			elif _selected:
				if is_instance_valid(_selected):
					_selected.deselect()
				_selected = null
				emit_signal("none_selected")
				Input.set_default_cursor_shape(Input.CURSOR_ARROW)
