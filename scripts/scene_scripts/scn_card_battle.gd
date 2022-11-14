extends Node2D


signal next_phase_triggered(phase)
signal player_won
signal player_lost

const GameCard = preload("res://objects/game_card.tscn")
const GameCardPlayer = preload("res://objects/game_card_player.tscn")
const UiCard = preload("res://objects/ui_card.tscn")

const SCORE_GOAL = 20

var player_lane_spaces = []
var player_lane_cards = []
var enemy_lane_spaces = []
var enemy_lane_cards = []

# 0	player play card
# 1 player attack
# 2 player move
# 3 opponent play card
# 4 opponent attack
# 5 opponent move
var _game_phase = 0

var _scores = [0, 0]

# Opponent deck, hand, and next up card
var _enemy_deck = []
var _enemy_hand = []
var _enemy_queued_card


# Builtin functions


func _init():
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
	
	begin_battle()


# Gameplay functions


func begin_battle():
	# Wait for scene transition
	yield(ScnUiOverlay.find_node("Tween"), "tween_all_completed")
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
	for i in range(2):
		draw_card()
		yield(get_tree().create_timer(0.2 * SettingsController.graphics_animate_speed), "timeout")
	
	enemy_choose_next_card()
	
	emit_signal("next_phase_triggered", 0)


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


func draw_card():
	var new_card = $GameDeck.get_card()
	if new_card == null:
		print("Deck is empty.")
		return
	new_card.connect("played", self, "_on_GameCard_played")
	new_card.connect("scored", self, "_on_GameCard_scored")
	new_card.global_position = $GameDeck.global_position
	$GameHand.addCard(new_card)


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
		i -= 1
	yield(get_tree(), "idle_frame")


func update_score(team, value):
	_scores[team] += value
	[$PlayerScore, $EnemyScore][team].text = str(_scores[team])


func enemy_choose_next_card():
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
	
	for card_id in _enemy_hand:
		var c_fitness = enemy_get_card_candidate_fitness(
			card_id,
			preferred_power,
			preferred_health,
			power_bias
		)
		if c_fitness > best_fitness:
			best_fitness = c_fitness
			best_card = card_id
	
	# Randomly pass if card fitness is not good enough
	if best_fitness < 3 and rand_range(best_fitness, 4) < 3:
		_enemy_queued_card = null
	else:
		_enemy_queued_card = best_card
	
	# Update next card visual
	if _enemy_queued_card:
		var card_preview = UiCard.instance().init(_enemy_queued_card)
		card_preview.scale = Vector2(0.6, 0.6)
		$LabelNextCard/Position2D.add_child(card_preview)


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
	var enemy_play_pos = enemy_lane_spaces[0].find_node("CenterPoint").global_position
	enemy_lane_cards[0] = card
	$BoardCards.add_child(card)
	card.scale = Vector2(0.8, 0.8)
	card.global_position = enemy_play_pos + Vector2(0, -400)
	card.slide_to_position(enemy_play_pos, 0.25)
	card.perform_played()


func _on_next_phase_triggered(phase: int):
	_game_phase = phase

	match _game_phase:
		0:	# player play card
			$DebugGamePhase.text = "player play"
			$GameHand.show()
			draw_card()
			$ButtonEndTurn.disabled = false
			
		1:	# player attack
			$DebugGamePhase.text = "player attack"
			$GameHand.hide()
			$ButtonEndTurn.disabled = true
			
			yield(make_cards_attack(player_lane_cards), "completed")
			
			yield(get_tree().create_timer(0.5 * SettingsController.graphics_animate_speed), "timeout")
			emit_signal("next_phase_triggered", 2)
		2:	# player move
			$DebugGamePhase.text = "player move"
			
			yield(move_cards(player_lane_cards), "completed")
			
			yield(get_tree().create_timer(1.0 * SettingsController.graphics_animate_speed), "timeout")
			if _scores[0] >= SCORE_GOAL:
				emit_signal("player_won")
			else:
				emit_signal("next_phase_triggered", 3)
		3:	# enemy play card
			$DebugGamePhase.text = "opponent play"
			
			if _enemy_queued_card and enemy_lane_cards[0] == null:
				_enemy_hand.erase(_enemy_queued_card)
				yield(enemy_play_card(_enemy_queued_card), "completed")
				_enemy_queued_card = null
			
			yield(get_tree().create_timer(0.5 * SettingsController.graphics_animate_speed), "timeout")
			emit_signal("next_phase_triggered", 4)
		4:	#enemy attack
			$DebugGamePhase.text = "opponent attack"
			
			yield(make_cards_attack(enemy_lane_cards), "completed")
			
			yield(get_tree().create_timer(0.5 * SettingsController.graphics_animate_speed), "timeout")
			emit_signal("next_phase_triggered", 5)
		5:	# enemy move
			$DebugGamePhase.text = "opponent move"
			
			yield(move_cards(enemy_lane_cards), "completed")
			
			yield(get_tree().create_timer(1.0 * SettingsController.graphics_animate_speed), "timeout")
			if _scores[1] >= SCORE_GOAL:
				emit_signal("player_lost")
			else:
				emit_signal("next_phase_triggered", 6)
		6:	# enemy draw
			$DebugGamePhase.text = "opponent draw"
			var card_id = _enemy_deck.pop_back()
			if card_id:
				_enemy_hand.append(card_id)
				enemy_choose_next_card()
			print("DEBUG: Enemy hand: " + str(_enemy_hand) + " Enemy deck: " + str(_enemy_deck.size()))
			emit_signal("next_phase_triggered", 0)


func _on_GameDeck_clicked():
	if _game_phase != 0:
		print("Cannot draw a card now.")
		return
	if _scores[0] == 0:
		print("Cannot afford to buy a card!")
		return
	update_score(0, -1)
	draw_card()


func _on_GameCard_played(card):
	if _game_phase != 0:
		print("Cannot play a card now.")
		return
	if player_lane_cards[0]:
		print("Already card in space.")
	else:
		card.disconnect("played", self, "_on_GameCard_played")
		player_lane_cards[0] = card
		var card_pos = card.global_position
		$GameHand.removeCard(card)
		$BoardCards.add_child(card)
		card.scale = Vector2(0.8, 0.8)
		card.global_position = card_pos
		card.slide_to_position(player_lane_spaces[0].find_node("CenterPoint").global_position, 0.25)
		card.perform_played()


func _on_GameCard_scored(team, value):
	update_score(team, value)


func _on_ScnCardBattle_player_lost():
	ScnUiOverlay.show()
	ScnUiOverlay.show_popup("battle_lost")


func _on_ScnCardBattle_player_won():
	ScnUiOverlay.show()
	ScnUiOverlay.show_popup("battle_won")


func _on_CardSelector_card_selected(card):
	if "card_id" in card:
		$HintBox/RichTextLabel.bbcode_text = "[center][color=blue]" + card.card_name + "[/color][/center]\n" + card.card_description


func _on_CardSelector_none_selected():
	$HintBox/RichTextLabel.bbcode_text = ""
