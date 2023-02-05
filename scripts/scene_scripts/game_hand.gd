extends Node2D
# The player's hand in battle, with the cards they can play in the current turn.


var active setget set_active

var _cards = []
var _card_positions = []
var _card_margin = 100

onready var node_animation_player = $AnimationPlayer
onready var node_cards = $Cards


func addCard(card):
	var card_pos = card.global_position
	node_cards.add_child(card)
	card.global_position = card_pos
	_cards.append(card)
	_card_positions.append(Vector2(0, 0))
	card.play_sound("deal_a")
	yield(calc_card_positions(), "completed")
	card.play_sound("deal_b")
	card.is_in_hand = true

func removeCard(card):
	var index = _cards.find(card)
	_cards.remove(index)
	node_cards.remove_child(card)
	_card_positions.remove(index)
	calc_card_positions()
	card.is_in_hand = false

func calc_card_positions():
	if _cards.size() == 0:
		return
	_card_margin = min(200, 1000 / _cards.size())
	var x = 0
	for i in _card_positions.size():
		var card_pos = Vector2(0, 0)
		card_pos.x = x
		card_pos = card_pos + global_position
		_card_positions[i] = card_pos
		_cards[i].slide_to_position(card_pos, 0.1, true)
		_cards[i].z_index = _cards[i].get_index()
		x += _card_margin
	yield(get_tree().create_timer(0.15), "timeout")


func set_active(value):
	for card in _cards:
		card.find_node("CollisionShape2D").set_deferred("disabled", !value)
	node_animation_player.play("slide_offscreen", -1, -1 if value else 1, value)
	yield(node_animation_player, "animation_finished")
