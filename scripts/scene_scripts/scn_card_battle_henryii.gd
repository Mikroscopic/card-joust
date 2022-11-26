extends ScnCardBattle


func _init():
	_level_index = 1
	_enemy_name = "Henry II of France"
	_enemy_portrait = "portrait_henryii.png"
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
			_enemy_queued_card = "MEDIEVAL_PEASANT"
		1:
			if randf() < 0.5:
				_enemy_queued_card = "MEDIEVAL_KNIGHT"
		2:
			if !enemy_lane_cards[1]:
				_enemy_queued_card = "MEDIEVAL_KNIGHT"
		_:
			match turn % 3:
				0:
					if randf() < 0.5:
						_enemy_queued_card = "MEDIEVAL_PEASANT"
				1:
					if enemy_lane_cards[1]:
						_enemy_queued_card = "MEDIEVAL_PEASANT"
					else:
						_enemy_queued_card = "MEDIEVAL_KNIGHT"
				2:
					if randf() < 0.5:
						_enemy_queued_card = "MEDIEVAL_BOSS_EYE"
					else:
						_enemy_queued_card = "MEDIEVAL_BOSS_HEART"
			if randf() < 0.1:
				_enemy_queued_card = "MEDIEVAL_BOSS_LANCE"
