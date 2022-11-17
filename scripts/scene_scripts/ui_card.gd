extends KinematicBody2D
# A representation of a card in UI previews, such as the "next card:" icon


const THEME_STATS = preload("res://assets/themes/theme_cd_stats.tres")
const THEME_STATS_DIGITS = preload("res://assets/themes/theme_cd_stats_digits.tres")

# card stats
var card_id: String
var card_name: String
var card_description: String
var power: int
var health: int
var value: int


func _ready():
	if (SettingsController.graphics_roman_numerals):
		find_node("Power").text = CardDictionary.get_numeral(power)
		find_node("Value").text = CardDictionary.get_numeral(value)
		find_node("Health").text = CardDictionary.get_numeral(health)
	else:
		find_node("Power").text = str(power)
		find_node("Value").text = str(value)
		find_node("Health").text = str(health)
	for stat in ["Power", "Value", "Health"]:
		var regex = RegEx.new()
		regex.compile("[0-9]")
		var n = find_node(stat)
		if regex.search(n.text):
			n.set_theme(THEME_STATS_DIGITS)
		else:
			n.set_theme(THEME_STATS)
	find_node("Name").text = card_name


func init(id: String):
	var card_data = CardDictionary.get_card_data(id)
	
	self.card_id = id
	self.card_name = card_data.name
	self.card_description = card_data.description
	
	if card_data.image_portrait != "":
		var img_portrait = Image.new()
		img_portrait.load("res://assets/sprites/cards/" + card_data.image_portrait)
		var tex_portrait = ImageTexture.new()
		tex_portrait.create_from_image(img_portrait)
		$Background/Art.texture = tex_portrait
	
	self.power = card_data.power
	self.value = card_data.value
	self.health = card_data.health
	
	return self


func slide_to_position(pos, time):
	time = time / SettingsController.graphics_animation_timescale
	$Tween.interpolate_property(self, "global_position", global_position, pos, time, Tween.TRANS_LINEAR)
	$Tween.start()
	yield($Tween, "tween_completed")


func select():
	pass


func deselect():
	pass
