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
		"description": "When attacking: Steals 1 value from the card it attacks and adds it to its own value",
		"image_bg": "",
		"image_portrait": "",
		"power": 1,
		"value": 0,
		"health": 3,
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
