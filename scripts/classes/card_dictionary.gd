class_name CardDictionary
extends Reference
# A dicitonary to define each card's appearance and stats.


const cards = {
	"MEDIEVAL_PEASANT": {
		"name": "PEASANT",
		"description": "",
		"image_bg": "",
		"image_portrait": "cd_art_peasant.png",
		"power": 1,
		"value": 2,
		"health": 3,
	},
	"MEDIEVAL_LORD": {
		"name": "LORD",
		"description": "",
		"image_bg": "",
		"image_portrait": "cd_art_lord.png",
		"power": 0,
		"value": 5,
		"health": 2,
	},
	"MEDIEVAL_KNIGHT": {
		"name": "KNIGHT",
		"description": "",
		"image_bg": "",
		"image_portrait": "cd_art_knight.png",
		"power": 2,
		"value": 2,
		"health": 3,
	},
	"MEDIEVAL_THIEF": {
		"name": "THIEF",
		"description": "Steals 1 value from each card it attacks and adds it " \
			+ "to its own value.",
		"image_bg": "",
		"image_portrait": "cd_art_thief.png",
		"power": 1,
		"value": 0,
		"health": 3,
	},
	"MEDIEVAL_ARCHER": {
		"name": "ARCHER",
		"description": "If no card occupies the opposing space, this card " \
			+ "will instead target the closest card behind that space " \
			+ "(toward the opponent's starting space).",
		"image_bg": "",
		"image_portrait": "cd_art_archer.png",
		"power": 2,
		"value": 2,
		"health": 2,
	},
	"MEDIEVAL_BOSS_LANCE": {
		"name": "BRITTLE LANCE",
		"description": "Dies after attacking for the first time.",
		"image_bg": "",
		"image_portrait": "",
		"power": 3,
		"value": 0,
		"health": 1,
	},
	"MEDIEVAL_BOSS_EYE": {
		"name": "SPLINTERED EYE",
		"description": "This card's attack power is equal to that of the " \
			+ "card in the opposing space.",
		"image_bg": "",
		"image_portrait": "",
		"power": 0,
		"value": 2,
		"health": 2,
	},
	"MEDIEVAL_BOSS_HEART": {
		"name": "PIERCED HEART",
		"description": "This card's attack power is equal to its health. " \
			+ "Gains 1 health at the end of its owner's turn.",
		"image_bg": "",
		"image_portrait": "",
		"power": 1,
		"value": 2,
		"health": 1,
	},
	"GREEK_BOSS_MIDAS_HAND": {
		"name": "HAND of MIDAS",
		"description": "Turns cards into gold statues. A gold statue cannot " \
			+ "attack, and can only move if a card in the space behind it " \
			+ "can move.",
		"image_bg": "",
		"image_portrait": "",
		"power": 1,
		"value": 4,
		"health": 2,
	},
}


static func get_card_data(id):
	return cards[id]


static func get_numeral(num):
	if num >= 20:
		return str(num)
	
	var numerals = [
		"0",
		"I",
		"II",
		"III",
		"IV",
		"V",
		"VI",
		"VII",
		"VIII",
		"IX",
		"X",
		"XI",
		"XII",
		"XIII",
		"XIV",
		"XV",
		"XVI",
		"XVII",
		"XVIII",
		"XIX",
	]
	return str(numerals[num])
