extends Node2D
# The player's hand in battle, with the cards they can play in the current turn.


var _cards = []
var _card_positions = []
var _card_margin = 100


func addCard(card):
	var card_pos = card.global_position
	add_child(card)
	card.global_position = card_pos
	_cards.append(card)
	_card_positions.append(Vector2(0, 0))
	calc_card_positions()
	card.is_in_hand = true

func removeCard(card):
	var index = _cards.find(card)
	_cards.remove(index)
	remove_child(card)
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
		_cards[i].slide_to_position(card_pos, 0.1)
		_cards[i].z_index = _cards[i].get_index()
		x += _card_margin
