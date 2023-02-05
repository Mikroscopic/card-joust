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

onready var node_tween = $Tween
onready var node_art = $Background/Art
onready var node_name = $Background/Name
onready var node_power = $Background/Power
onready var node_value = $Background/Value
onready var node_health = $Background/Health

func _ready():
	if (SettingsController.graphics_roman_numerals):
		node_power.text = CardDictionary.get_numeral(power)
		node_value.text = CardDictionary.get_numeral(value)
		node_health.text = CardDictionary.get_numeral(health)
	else:
		node_power.text = str(power)
		node_value.text = str(value)
		node_health.text = str(health)
	for stat in ["Power", "Value", "Health"]:
		var regex = RegEx.new()
		regex.compile("[0-9]")
		var n = find_node(stat)
		if regex.search(n.text):
			n.set_theme(THEME_STATS_DIGITS)
		else:
			n.set_theme(THEME_STATS)
	node_name.text = card_name
	if card_name.length() > 12:
		var name_scale = min(1.0, 12.0 / card_name.length())
		node_name.rect_scale = Vector2(name_scale, name_scale)


func init(id: String):
	var card_data = CardDictionary.get_card_data(id)
	
	self.card_id = id
	self.card_name = card_data.name
	self.card_description = card_data.description
	
	if card_data.image_portrait != "":
		$Background/Art.texture = load("res://assets/sprites/cards/" + card_data.image_portrait)
	
	self.power = card_data.power
	self.value = card_data.value
	self.health = card_data.health
	
	return self


func slide_to_position(pos, time):
	time = time / SettingsController.graphics_animation_timescale
	node_tween.interpolate_property(self, "global_position", global_position, pos, time, Tween.TRANS_LINEAR)
	node_tween.start()
	yield(node_tween, "tween_completed")


func select():
	pass


func deselect():
	pass
