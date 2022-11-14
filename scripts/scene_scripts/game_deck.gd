extends Node2D
# The player's deck of cards in battle.


signal clicked

const CARD_BACK_TEXTURE = preload("res://assets/sprites/cards/cd_back.png")
const GameCardPlayer = preload("res://objects/game_card_player.tscn")

# The last element is the top of the deck
var _cards:Array

var _is_selected

var _card_margin = 10


# Builtin functions


func _ready():
	_cards = CardCollection.active_deck.duplicate(true)
	_is_selected = false
	
	if _cards.size() > 0:
		_card_margin = min(10, int(50 / _cards.size()))
	$DeckVisual/CardSprites.add_constant_override("separation", _card_margin)
	for i in range(_cards.size()):
		var sprite_control = Control.new()
		var sprite = Sprite.new()
		sprite.texture = CARD_BACK_TEXTURE
		sprite.scale = Vector2(0.5, 0.5)
		sprite.rotation_degrees = 45
		sprite_control.add_child(sprite)
		#sprite.position.y = -_card_margin * i
		$DeckVisual/CardSprites.add_child(sprite_control)


func _physics_process(delta):
	if Input.is_action_just_pressed("mouse_left") and _is_selected:
		emit_signal("clicked")


# Gameplay functions


func shuffle():
	_cards.shuffle()


func get_card():
	if _cards.size() == 0:
		$CollisionShape2D.set_deferred("disabled", true)
		return null
	
	# Remove a card
	var card_id = _cards.pop_back()
	$DeckVisual/CardSprites.get_child(_cards.size()).queue_free()
	
	# Reorganize the deck
	if _cards.size() > 0:
		_card_margin = min(10, int(50 / _cards.size()))
		$DeckVisual/CardSprites.add_constant_override("separation", _card_margin)
	else:
		$CollisionShape2D.set_deferred("disabled", true)
	
	# Return a card with the appropriate stats
	return GameCardPlayer.instance().init(card_id)


func select():
	_is_selected = true


func deselect():
	_is_selected = false
