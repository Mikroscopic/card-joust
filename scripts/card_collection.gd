extends Node
# The inventory of cards that the player possesses.


var collected_deck:Dictionary
var active_deck:Array


func _ready():
	collected_deck = {
		"MEDIEVAL_PEASANT": 5,
		"MEDIEVAL_LORD": 5,
		"MEDIEVAL_KNIGHT": 5,
		"MEDIEVAL_THIEF": 2,
		"MEDIEVAL_ARCHER": 3,
	}
	active_deck = []
	
	for card_id in collected_deck.keys():
		for count in collected_deck[card_id]:
			active_deck.append(card_id)
