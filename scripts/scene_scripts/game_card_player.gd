class_name GameCardPlayer
extends GameCard
# A card as it exists in battle, owned by the player.
# Extends parent to add logic for selecting and playing the card.


signal played(card)

# UI events
var is_in_hand = false
var _is_selected = false
var _is_shown_selected = false


# Builtin functions


func _init():
	_card_owner = 0


func _physics_process(delta):
	var s = SettingsController.graphics_animation_timescale
	if Input.is_action_just_pressed("mouse_left") and _is_selected:
		emit_signal("played", self)
		$Tween.interpolate_property($CardVisual, "position", $CardVisual.position, Vector2(0, 0), 0.1 / s)
		$Tween.start()
		_is_shown_selected = false
	
	if is_in_hand and _is_selected and not _is_shown_selected:
		z_index = get_parent().get_child_count()
		$Tween.interpolate_property($CardVisual, "position", Vector2(0, 0), Vector2(0, -20), 0.1 / s)
		$Tween.start()
		_is_shown_selected = true
	
	if is_in_hand and not _is_selected and _is_shown_selected:
		z_index = get_index()
		$Tween.interpolate_property($CardVisual, "position", Vector2(0, -20), Vector2(0, 0), 0.1 / s)
		$Tween.start()
		_is_shown_selected = false


# Visual and animation functions


func select():
	_is_selected = true


func deselect():
	_is_selected = false
