extends ScnCardBattle


func _init():
	_enemy_name = "King Midas"
	_enemy_portrait = "portrait_midas.png"
	_enemy_deck = [
		"MEDIEVAL_PEASANT",
		"MEDIEVAL_PEASANT",
		"MEDIEVAL_PEASANT",
		"MEDIEVAL_PEASANT",
		"MEDIEVAL_PEASANT",
		"MEDIEVAL_PEASANT",
		"MEDIEVAL_PEASANT",
		"MEDIEVAL_LORD",
		"MEDIEVAL_LORD",
		"MEDIEVAL_LORD",
		"MEDIEVAL_LORD",
		"MEDIEVAL_KNIGHT",
		"MEDIEVAL_KNIGHT",
		"MEDIEVAL_KNIGHT",
		"MEDIEVAL_KNIGHT",
	]


func enemy_choose_next_card():
	match turn:
		0:
			_enemy_queued_card = "MEDIEVAL_THIEF"
		1:
			if randf() < 0.5:
				_enemy_queued_card = "MEDIEVAL_THIEF"
		2:
			if !enemy_lane_cards[1]:
				_enemy_queued_card = "MEDIEVAL_THIEF"
		_:
			match turn % 3:
				0:
					if randf() < 0.5:
						_enemy_queued_card = "GREEK_BOSS_MIDAS_HAND"
				1:
					if !enemy_lane_cards[1]:
						_enemy_queued_card = "MEDIEVAL_LORD"
					else:
						_enemy_queued_card = "MEDIEVAL_THIEF"
				2:
					if randf() < 0.5:
						_enemy_queued_card = "GREEK_BOSS_MIDAS_HAND"
					else:
						_enemy_queued_card = "MEDIEVAL_KNIGHT"
