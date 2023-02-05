extends ScnCardBattle


var first_played_card
var gave_score_lesson = false


func begin_battle():
	node_animation_player.play("seq_tutorial_reset")
	yield(node_animation_player, "animation_finished")
	# Wait for scene transition
	if ScnUiOverlay.find_node("Tween").is_active():
		yield(ScnUiOverlay.find_node("Tween"), "tween_all_completed")
	
	# Set up the enemy's cards
	_enemy_deck.shuffle()
	for i in range(3):
		var card_id = _enemy_deck.pop_back()
		_enemy_hand.append(card_id)
	
	node_game_deck.shuffle()
	node_game_deck.load_top_deck("MEDIEVAL_THIEF")
	node_game_deck.load_top_deck("MEDIEVAL_KNIGHT")
	node_game_deck.load_top_deck("MEDIEVAL_PEASANT")
	node_game_deck.load_top_deck("MEDIEVAL_KNIGHT")
	node_game_deck.load_top_deck("MEDIEVAL_LORD")
	node_game_deck.load_top_deck("MEDIEVAL_PEASANT")
	
	play_tutorial()


func play_tutorial():
	yield(get_tree().create_timer(0.5, false), "timeout")
	ScnUiDialogue.active_box = 2
	ScnUiDialogue.messages = [
		"Since ancient times, humanity has engaged in countless forms of martial games.",
		"But few have ever been as grand a spectacle as the joust.",
		"The joust is no mere theatrical performance, but indeed a ruthless trial of bravery and skill.",
		"Many have entered the lists. Few have returned unscathed.",
		"To emerge victorious, one must play their cards right.",
		"Well... technically, you must play them on the left.",
	]
	yield(ScnUiDialogue, "messages_finished")
	
	# Reveal the first space and player's deck
	node_animation_player.play("seq_tutorial_001")
	yield(node_animation_player, "animation_finished")
	
	# Draw cards for player's initial hand
	yield(draw_card(3), "completed")
	
	node_debug_game_phase.text = "player play"
	
	ScnUiDialogue.active_box = 0
	ScnUiDialogue.messages = ["Pick a card."]
	# Wait for player to play a card
	yield(node_board_cards, "child_entered_tree")
	first_played_card = player_lane_cards[0].card_name
	yield(get_tree().create_timer(0.5, false), "timeout")
	
	ScnUiDialogue.messages = [
		"Your [color=blue]" + first_played_card + "[/color] steps forth.",
	]
	yield(ScnUiDialogue, "messages_finished")
	
	# Reveal the rest of the spaces in the player lane
	node_animation_player.play("seq_tutorial_002")
	yield(node_animation_player, "animation_finished")
	
	ScnUiDialogue.messages = [
		("Glory lies at the other end of the lane. "
		+ "Get your cards there, and you will be rewarded."),
		"Now, give the command to charge.",
	]
	yield(ScnUiDialogue, "messages_finished")
	
	# Reveal the button
	node_button_end_turn.disabled = false
	node_animation_player.play("seq_tutorial_003")
	yield(self, "next_phase_triggered")
	# Normal game loop begins from here


func enemy_choose_next_card():
	match turn:
		0:
			pass
		_:
			match turn % 3:
				0:
					_enemy_queued_card = null
				1:
					_enemy_queued_card = "MEDIEVAL_PEASANT"
				2:
					_enemy_queued_card = "MEDIEVAL_LORD"


func perform_player_play():
	node_debug_game_phase.text = "player play"
	turn += 1
	
	match turn:
		1:
			ScnUiDialogue.active_box = 1
			ScnUiDialogue.messages = [
				("A challenger approaches, eager to clash with your "
				+ "[color=blue]" + first_played_card + "[/color]."),
				("You may place another card at the start of your lane, "
				+ "or you may choose to pass."),
				"Call for another charge when you are ready.",
			]
			yield(ScnUiDialogue, "messages_finished")
		2:
			ScnUiDialogue.messages = [
				("Each player's turn begins with an "
				+ "[color=blue]attack phase[/color]. "
				+ "Each of their cards will strike the opposing card in "
				+ "their enemy's lane."),
				("A card's [color=blue]attack power[/color] indicates "
				+ "the amount of damage it inflicts. "
				+ "Its [color=blue]health[/color] defines the amount of "
				+ "damage it can withstand before it dies."),
				("After the attack phase, each card will "
				+ "[color=blue]move[/color] one space down the lane."),
				("Timing is crucial. See what your enemy has planned, "
				+ "and act accordingly."),
			]
			yield(ScnUiDialogue, "messages_finished")
			node_animation_player.play("seq_tutorial_005")
			yield(node_animation_player, "animation_finished")
			
			ScnUiDialogue.active_box = 0
			ScnUiDialogue.messages = [
				"It is your turn once again.",
			]
			yield(ScnUiDialogue, "messages_finished")
	
	yield(node_game_hand.set_active(true), "completed")
	draw_card()
	node_button_end_turn.disabled = false
	
	match turn:
		3:
			ScnUiDialogue.active_box = 0
			ScnUiDialogue.messages = [
				("Some cards have special abilities. "
				+ "Hover your hand over any card in your sight, and sense "
				+ "its power."),
			]
			node_animation_player.play("seq_tutorial_006")
			yield(node_animation_player, "animation_finished")


func perform_player_move():
	node_debug_game_phase.text = "player move"
	
	yield(move_cards(player_lane_cards), "completed")
	
	if player_lane_cards.count(null) != len(player_lane_cards):
		yield(get_tree().create_timer(0.5, false), "timeout")
	if _scores[0] >= SCORE_GOAL:
		emit_signal("player_won")
	else:
		if _scores[0] > 0 and !gave_score_lesson:
			ScnUiDialogue.active_box = 0
			ScnUiDialogue.messages = [
				("When a card reaches the end of its lane, its owner is "
				+ "rewarded with [color=blue]valor[/color], according to "
				+ "the card's value."),
				("The battle is won by whoever reaches a total of "
				+ "[color=blue]20 valor[/color] first."),
				("You may also spend valor to draw extra cards from your deck "
				+ "during your turn."),
			]
			yield(ScnUiDialogue, "messages_finished")
			gave_score_lesson = true
		emit_signal("next_phase_triggered", 3)


func perform_enemy_play():
	node_debug_game_phase.text = "opponent play"
	
	var card
	match turn:
		0:
			ScnUiDialogue.messages = [
				("Your [color=blue]" + first_played_card + "[/color] marches "
				+ "forward, toward the goal."),
				"But its path is not without obstacles.",
			]
			yield(ScnUiDialogue, "messages_finished")
			
			# Refveal enemy lane
			node_animation_player.play("seq_tutorial_004")
			yield(node_animation_player, "animation_finished")
			
			card = "MEDIEVAL_KNIGHT"
		_:
			card = _enemy_queued_card
	
	if card:
		_enemy_queued_card = null
		yield(enemy_play_card(card), "completed")
		yield(get_tree().create_timer(0.5, false), "timeout")
	
	emit_signal("next_phase_triggered", 4)


func perform_enemy_attack():
	node_debug_game_phase.text = "opponent attack"
	
	match turn:
		1:
			ScnUiDialogue.messages = [
				("Your cards move once more. Your [color=blue]"
				+ first_played_card + "[/color] now opposes the "
				+ "enemy [color=red]KNIGHT[/color]."),
				"The enemy takes action, and seizes the opportunity to attack.",
			]
			yield(ScnUiDialogue, "messages_finished")
	
	yield(make_cards_attack(enemy_lane_cards), "completed")
	
	if enemy_lane_cards.count(null) != len(enemy_lane_cards):
		yield(get_tree().create_timer(0.5, false), "timeout")
	
	match turn:
		1:
			ScnUiDialogue.messages = [
				("Your [color=blue]" + first_played_card + "[/color] "
				+ "suffers [color=red]2[/color] damage at the hands of the "
				+ "enemy [color=red]KNIGHT[/color]."
				+ ("" if player_lane_cards[2] else " The blow is fatal.")),
			]
			yield(ScnUiDialogue, "messages_finished")
	
	emit_signal("next_phase_triggered", 5)


func perform_enemy_move():
	node_debug_game_phase.text = "opponent move"
	
	yield(move_cards(enemy_lane_cards), "completed")
	
	if enemy_lane_cards.count(null) != len(enemy_lane_cards):
		yield(get_tree().create_timer(0.5, false), "timeout")
	if _scores[1] >= SCORE_GOAL:
		emit_signal("player_lost")
	else:
		if _scores[1] > 0 and !gave_score_lesson:
			ScnUiDialogue.active_box = 1
			ScnUiDialogue.messages = [
				("When a card reaches the end of its lane, its owner is "
				+ "rewarded with [color=blue]valor[/color], according to "
				+ "the card's value."),
				("The battle is won by whoever reaches a total of "
				+ "[color=blue]20 valor[/color] first."),
				("You may also spend valor to draw extra cards from your deck "
				+ "during your turn."),
			]
			yield(ScnUiDialogue, "messages_finished")
			gave_score_lesson = true
		emit_signal("next_phase_triggered", 6)


func _on_ScnCardBattle_player_lost():
	ScnUiDialogue.active_box = 1
	ScnUiDialogue.messages = [
		"You... have lost.",
		"This battle was not meant to be a challenge...",
		"But you are a novice, after all. Try again.",
	]
	yield(ScnUiDialogue, "messages_finished")
	SceneController.reload_scene_fade(1.0)


func _on_ScnCardBattle_player_won():
	SceneController.set_level_completed(0)
	ScnUiDialogue.active_box = 1
	ScnUiDialogue.messages = [
		"You have fought well.",
		"It is time to battle a real enemy. Good luck.",
	]
	yield(ScnUiDialogue, "messages_finished")
	SceneController.change_scene_fade("res://scenes/scn_card_battle_henryii.tscn", 1.0)
