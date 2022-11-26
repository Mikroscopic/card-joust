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
		_card_margin = min(10, int(50 / min(_cards.size(), 10)))
	$DeckVisual/CardSprites.add_constant_override("separation", _card_margin)
	for i in range(min(_cards.size(), 10)):
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


func load_top_deck(card_id: String):
	var i = _cards.find(card_id)
	if i >= 0:
		var card = _cards.pop_at(i)
		_cards.append(card)


func get_card():
	if _cards.size() == 0:
		$CollisionShape2D.set_deferred("disabled", true)
		return null
	
	# Remove a card
	var card_id = _cards.pop_back()
	if _cards.size() < 10:
		$DeckVisual/CardSprites.get_child(_cards.size()).queue_free()
	
	# Reorganize the deck
	if _cards.size() > 0:
		_card_margin = min(10, int(50 / $DeckVisual/CardSprites.get_child_count()))
		$DeckVisual/CardSprites.add_constant_override("separation", _card_margin)
	else:
		$CollisionShape2D.set_deferred("disabled", true)
	
	# Return a card with the appropriate stats
	return GameCardPlayer.instance().init(card_id)


func cards_size():
	return _cards.size()


func select():
	_is_selected = true


func deselect():
	_is_selected = false
