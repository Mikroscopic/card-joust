class_name ScnCardBattle
extends Node2D


signal next_phase_triggered(phase)
signal board_state_changed
signal player_won
signal player_lost

const GameCard = preload("res://objects/game_card.tscn")
const GameCardPlayer = preload("res://objects/game_card_player.tscn")
const UiCard = preload("res://objects/ui_card.tscn")

const SCORE_GOAL = 20

var turn = 0
var player_lane_spaces = []
var player_lane_cards = []
var enemy_lane_spaces = []
var enemy_lane_cards = []

var _level_index
# 0	player play card
# 1 player attack
# 2 player move
# 3 opponent play card
# 4 opponent attack
# 5 opponent move
var _game_phase = 0

var _scores = [0, 0]

var _enemy_name
var _enemy_portrait
# Opponent deck, hand, and next up card
var _enemy_deck = []
var _enemy_hand = []
var _enemy_queued_card


# Builtin functions


func _init():
	_level_index = 0
	_enemy_name = "Placeholder"
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


func _ready():
	# Seed randomizer
	randomize()
	#seed(hash(1))
	
	# Initialize player lane
	player_lane_spaces = $GameBoard/PlayerLane/CardSpaces.get_children()
	for i in range(player_lane_spaces.size()):
		player_lane_cards.append(null)
	player_lane_spaces.append($GameBoard/PlayerLane/EndSpace)
	
	# Initialize enemy lane
	enemy_lane_spaces = $GameBoard/EnemyLane/CardSpaces.get_children()
	enemy_lane_spaces.invert()
	for i in range(enemy_lane_spaces.size()):
		enemy_lane_cards.append(null)
	enemy_lane_spaces.append($GameBoard/EnemyLane/EndSpace)
	
	# Enemy name and portrait
	$Portrait/Name.text = _enemy_name
	var img_portrait = Image.new()
	img_portrait.load("res://assets/sprites/portraits/" + _enemy_portrait)
	var tex_portrait = ImageTexture.new()
	tex_portrait.create_from_image(img_portrait)
	$Portrait/Head.texture = tex_portrait
	
	begin_battle()


# Gameplay functions


func begin_battle():
	# Wait for scene transition
	if ScnUiOverlay.find_node("Tween").is_active():
		yield(ScnUiOverlay.find_node("Tween"), "tween_all_completed")
	$AnimationPlayer.play("portrait_introduce")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("scene_slide_in")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("portrait_to_corner")
	ScnUiOverlay.show()
	yield(ScnUiOverlay.animate_popup("battle_begin"), "completed")
	ScnUiOverlay.hide_popup()
	ScnUiOverlay.hide()
	
	# Set up the enemy's cards
	_enemy_deck.shuffle()
	for i in range(3):
		var card_id = _enemy_deck.pop_back()
		_enemy_hand.append(card_id)
	
	# Shuffle the deck
	$GameDeck.shuffle()
	# Draw cards for player's initial hand
	yield(draw_card(3), "completed")
	
	enemy_choose_next_card()
	# Update next card visual
	if _enemy_queued_card:
		var card_preview = UiCard.instance().init(_enemy_queued_card)
		card_preview.scale = Vector2(0.6, 0.6)
		$LabelNextCard/Position2D.add_child(card_preview)
	turn += 1
	
	#emit_signal("next_phase_triggered", 0)
	$DebugGamePhase.text = "player play"
	$ButtonEndTurn.disabled = false


func generate_card(owner:int = 0):
	var new_card
	match owner:
		0:
			new_card = GameCardPlayer.instance()
		1:
			new_card = GameCard.instance()
	match randi() % 3:
		0:
			new_card.init("MEDIEVAL_PEASANT")
		1:
			new_card.init("MEDIEVAL_LORD")
		2:
			new_card.init("MEDIEVAL_KNIGHT")
	new_card.connect("played", self, "_on_GameCard_played")
	new_card.connect("scored", self, "_on_GameCard_scored")
	return new_card


func draw_card(count = 1):
	var new_cards = []
	for i in range(count):
		var new_card = $GameDeck.get_card()
		if new_card == null:
			break
		new_card.global_position = $GameDeck.global_position
		$GameHand.addCard(new_card)
		new_cards.append(new_card)
		yield(
			get_tree().create_timer(
				0.2 / SettingsController.graphics_animation_timescale,
				false
			),
			"timeout"
		)
	for card in new_cards:
		card.connect("played", self, "_on_GameCard_played")
		card.connect("scored", self, "_on_GameCard_scored")
	yield(get_tree(), "idle_frame")


func make_cards_attack(lane):
	for card in lane:
		if card:
			yield(card.attack(), "completed")
	yield(get_tree(), "idle_frame")


func move_cards(lane):
	# iterate backwards through cards in lane
	var i = lane.size() - 1
	while i >= 0:
		if lane[i]:
			yield(lane[i].travel(), "completed")
			emit_signal("board_state_changed")
		i -= 1
	yield(get_tree(), "idle_frame")


func update_score(team, value):
	_scores[team] += value
	[$PlayerScore, $EnemyScore][team].text = str(_scores[team])


func enemy_choose_next_card():
	enemy_smart_card_choose()


func enemy_smart_card_choose():
	var card_id = _enemy_deck.pop_back()
	if card_id:
		_enemy_hand.append(card_id)
	else:
		return
	
	var best_fitness = -1
	var best_card
	
	var preferred_power = 0
	var preferred_health = 1
	var power_bias = 0.0
	
	var pc1 = player_lane_cards[1]
	var pc2 = player_lane_cards[2]
	# Look at what will end up attacking this card during the player's next turn
	var ec1willexist = enemy_lane_cards[1] and (not pc2 or enemy_lane_cards[1].health - pc2.power > 0)
	if pc1 and not (ec1willexist and pc1.health - enemy_lane_cards[1].power <= 0):
		preferred_health = pc1.power + 1
	
	# Look at what this card will end up attacking the next turn
	# Place higher importance on killing high value cards
	if pc2:
		preferred_power = pc2.health
		power_bias = (pc2.value) / 2.0
	
	for c_id in _enemy_hand:
		var c_fitness = enemy_get_card_candidate_fitness(
			c_id,
			preferred_power,
			preferred_health,
			power_bias
		)
		if c_fitness > best_fitness:
			best_fitness = c_fitness
			best_card = c_id
	
	# Randomly pass if card fitness is not good enough
	if best_fitness < 3 and rand_range(best_fitness, 4) < 3:
		_enemy_queued_card = null
	else:
		_enemy_queued_card = best_card


func enemy_get_card_candidate_fitness(
	card_id: String,
	preferred_power: int,
	preferred_health: int,
	power_bias: float
):
	var card_stats = CardDictionary.cards[card_id]
	var fitness = 0.0
	
	if card_stats.power >= preferred_power:
		fitness += power_bias + card_stats.power / 2
	else:
		fitness += card_stats.power / 2
	
	if card_stats.health >= preferred_health:
		fitness += card_stats.health / 2 + card_stats.value - 1
	else:
		fitness -= 1
	
	return fitness


func enemy_play_card(card_id: String):
	for n in $LabelNextCard/Position2D.get_children():
		yield(n.slide_to_position(n.global_position + Vector2(0, -400), 0.25), "completed")
		n.queue_free()
	yield(get_tree(), "idle_frame")
	
	var card = GameCard.instance().init(card_id)
	card.connect("scored", self, "_on_GameCard_scored")
	self.connect("board_state_changed", card, "_on_board_state_changed")
	var enemy_play_pos = enemy_lane_spaces[0].find_node("CenterPoint").global_position
	enemy_lane_cards[0] = card
	$BoardCards.add_child(card)
	card.scale = Vector2(0.8, 0.8)
	card.global_position = enemy_play_pos + Vector2(0, -400)
	card.slide_to_position(enemy_play_pos, 0.25)
	emit_signal("board_state_changed")
	card.perform_played()


func check_bankruptcy():
	if ($GameDeck.cards_size() == 0
		and $GameHand/Cards.get_child_count() == 0
		and player_lane_cards.count(null) == len(player_lane_cards)
	):
		ScnUiDialogue.active_box = 1
		ScnUiDialogue.messages = [
			"It seems you are out of cards.",
			"Unfortunately, victory is impossible. You must try again.",
		]
		yield(ScnUiDialogue, "messages_finished")
		emit_signal("player_lost")


func perform_player_play():
	$DebugGamePhase.text = "player play"
	turn += 1
	yield($GameHand.set_active(true), "completed")
	draw_card()
	$ButtonEndTurn.disabled = false


func perform_player_attack():
	$DebugGamePhase.text = "player attack"
	$GameHand.active = false
	$ButtonEndTurn.disabled = true
	
	yield(make_cards_attack(player_lane_cards), "completed")
			
	if player_lane_cards.count(null) != len(player_lane_cards):
		yield(get_tree().create_timer(0.5, false), "timeout")
	emit_signal("next_phase_triggered", 2)


func perform_player_move():
	$DebugGamePhase.text = "player move"
	
	yield(move_cards(player_lane_cards), "completed")
	
	if player_lane_cards.count(null) != len(player_lane_cards):
		yield(get_tree().create_timer(0.5, false), "timeout")
	if _scores[0] >= SCORE_GOAL:
		emit_signal("player_won")
	else:
		emit_signal("next_phase_triggered", 3)


func perform_enemy_play():
	$DebugGamePhase.text = "opponent play"
	
	if _enemy_queued_card and enemy_lane_cards[0] == null:
		_enemy_hand.erase(_enemy_queued_card)
		var card = _enemy_queued_card
		_enemy_queued_card = null
		yield(enemy_play_card(card), "completed")
		yield(get_tree().create_timer(0.5, false), "timeout")
	
	emit_signal("next_phase_triggered", 4)


func perform_enemy_attack():
	$DebugGamePhase.text = "opponent attack"
	
	yield(make_cards_attack(enemy_lane_cards), "completed")
	
	if enemy_lane_cards.count(null) != len(enemy_lane_cards):
		yield(get_tree().create_timer(0.5, false), "timeout")
	emit_signal("next_phase_triggered", 5)


func perform_enemy_move():
	$DebugGamePhase.text = "opponent move"
	
	yield(move_cards(enemy_lane_cards), "completed")
	
	if enemy_lane_cards.count(null) != len(enemy_lane_cards):
		yield(get_tree().create_timer(0.5, false), "timeout")
	if _scores[1] >= SCORE_GOAL:
		emit_signal("player_lost")
	else:
		emit_signal("next_phase_triggered", 6)


func perform_enemy_pick():
	$DebugGamePhase.text = "opponent draw"
	
	enemy_choose_next_card()
	
	# Update next card visual
	if _enemy_queued_card:
		var card_preview = UiCard.instance().init(_enemy_queued_card)
		card_preview.scale = Vector2(0.6, 0.6)
		$LabelNextCard/Position2D.add_child(card_preview)
	
	emit_signal("next_phase_triggered", 0)


func _on_next_phase_triggered(phase: int):
	_game_phase = phase

	match _game_phase:
		0:
			check_bankruptcy()
			perform_player_play()
		1:
			perform_player_attack()
		2:
			perform_player_move()
		3:
			perform_enemy_play()
		4:
			perform_enemy_attack()
		5:
			perform_enemy_move()
		6:
			perform_enemy_pick()


func _on_GameDeck_clicked():
	if _game_phase != 0:
		return
	if _scores[0] == 0:
		return
	update_score(0, -1)
	draw_card()


func _on_GameCard_played(card):
	if _game_phase != 0:
		return
	if player_lane_cards[0]:
		return

	card.disconnect("played", self, "_on_GameCard_played")
	self.connect("board_state_changed", card, "_on_board_state_changed")
	player_lane_cards[0] = card
	var card_pos = card.global_position
	$GameHand.removeCard(card)
	$BoardCards.add_child(card)
	card.scale = Vector2(0.8, 0.8)
	card.global_position = card_pos
	card.slide_to_position(player_lane_spaces[0].find_node("CenterPoint").global_position, 0.15, true)
	emit_signal("board_state_changed")
	card.perform_played()


func _on_GameCard_scored(team, value):
	update_score(team, value)


func _on_ScnCardBattle_player_lost():
	ScnUiOverlay.show()
	ScnUiOverlay.show_popup("battle_lost")


func _on_ScnCardBattle_player_won():
	SceneController.set_level_completed(_level_index)
	ScnUiOverlay.show()
	ScnUiOverlay.show_popup("battle_won")


func _on_CardSelector_card_selected(card):
	if "card_id" in card:
		$HintBox/RichTextLabel.bbcode_text = (
			"[center][color=blue]"
			+ card.card_name
			+ "[/color]\n[color=grey]"
			+ str(card.power)+ " ATK | "
			+ str(card.value) + " VAL | "
			+ str(card.health) + " HLT"
			+ "[/color][/center]\n"
			+ card.card_description
		)


func _on_CardSelector_none_selected():
	$HintBox/RichTextLabel.bbcode_text = ""
