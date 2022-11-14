class_name GameCard
extends Node2D
# A card as it exists in battle.
# Includes logic for attacking, taking damage, moving, and animating.


signal scored(team, value)

const THEME_STATS = preload("res://assets/themes/theme_cd_stats.tres")
const THEME_STATS_DIGITS = preload("res://assets/themes/theme_cd_stats_digits.tres")

# Card stats
var card_id: String
var card_name: String
var card_description: String
var power: int
var health: int
var value: int

# Reference to the battle scene parent node
var _battle_scene

#	0: player
#	1: enemy
var _card_owner: int
# The lane that this card occupies
var _ally_lane
# The lane that this card attacks
var _enemy_lane
# The space that this card currently occupies in its lane
var _lane_space: int
# The space(s) that this card is targeting for its next attack
var _targets: Array


# Builtin functions


func _init():
	_card_owner = 1


func _ready():
	_targets = []
	update_stats()
	find_node("Name").text = card_name
	_battle_scene = get_tree().current_scene
	if _card_owner == 0:
		_ally_lane = _battle_scene.player_lane_cards
		_enemy_lane = _battle_scene.enemy_lane_cards
	else:
		_ally_lane = _battle_scene.enemy_lane_cards
		_enemy_lane = _battle_scene.player_lane_cards


func init (id: String):
	var card_data = CardDictionary.get_card_data(id)
	
	self.card_id = id
	self.card_name = card_data.name
	self.card_description = card_data.description
	
	if card_data.image_portrait != "":
		var img_portrait = Image.new()
		img_portrait.load("res://assets/sprites/cards/" + card_data.image_portrait)
		var tex_portrait = ImageTexture.new()
		tex_portrait.create_from_image(img_portrait)
		$CardVisual/Art.texture = tex_portrait
	
	self.power = card_data.power
	self.value = card_data.value
	self.health = card_data.health
	
	return self


# Visual and animation functions


func update_stats():
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


func slide_to_position(pos, time):
	time = time * SettingsController.graphics_animate_speed
	$Tween.interpolate_property(self, "global_position", global_position, pos, time, Tween.TRANS_LINEAR)
	$Tween.start()
	yield($Tween, "tween_completed")


func animate(animation):
	var s = SettingsController.graphics_animate_speed
	match animation:
		"shake":
			$Tween.interpolate_property($CardVisual, "position", Vector2(0, 0), Vector2(-10, 0), 0.025*s, Tween.TRANS_LINEAR)
			$Tween.interpolate_property($CardVisual, "position", Vector2(-10, 0), Vector2(10, 0), 0.05*s, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.025)
			$Tween.interpolate_property($CardVisual, "position", Vector2(10, 0), Vector2(0, 0), 0.025*s, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.075)
		"move_forward":
			var offset = Vector2(0, -20) if _card_owner == 0 else Vector2(0, 20)
			$Tween.interpolate_property($CardVisual, "position", Vector2(0, 0), offset, 0.05*s, Tween.TRANS_LINEAR)
		"move_backward":
			var offset = Vector2(0, -20) if _card_owner == 0 else Vector2(0, 20)
			$Tween.interpolate_property($CardVisual, "position", offset, Vector2(0, 0), 0.05*s, Tween.TRANS_LINEAR)
	$Tween.start()
	yield($Tween, "tween_all_completed")


func select():
	pass


func deselect():
	pass


# Gameplay functions


func find_targets():
	_targets.clear()
	
	match card_id:
		"":
			pass
		_:
			var opposite_space = _enemy_lane.size() - _lane_space - 1
			_targets.append(opposite_space)


func attack():
	if power == 0:
		yield(get_tree(), "idle_frame")
		return
	
	yield(perform_pre_attack(), "completed")
	yield(perform_attack(), "completed")
	yield(perform_post_attack(), "completed")
	update_stats()


func travel():
	yield(perform_pre_travel(), "completed")
	yield(perform_travel(), "completed")
	if _lane_space < _ally_lane.size():
		yield(perform_post_travel(), "completed")
		update_stats()


func perform_played():
	_lane_space = 0
	find_targets()


func perform_pre_attack():
	yield(get_tree(), "idle_frame")


func perform_attack():
	for t in _targets:
		if _enemy_lane[t]:
			yield(animate("move_forward"), "completed")
			match card_id:
				"MEDIEVAL_THIEF":
					var v = _enemy_lane[t].value
					if v > 0:
						_enemy_lane[t].value = v - 1
						value += 1
				_:
					pass
			var opposing_card_killed = _enemy_lane[t].take_damage(self, power)
			yield(animate("move_backward"), "completed")
	yield(get_tree(), "idle_frame")


func perform_post_attack():
	yield(get_tree(), "idle_frame")


func perform_pre_travel():
	yield(get_tree(), "idle_frame")


func perform_travel():
	# Find the new position to move to
	var new_space
	var new_position
	var end_space = _ally_lane.size()
	
	match card_id:
		"":
			pass
		_:
			new_space = _lane_space + 1
	
	new_space = min(new_space, end_space)
	if _card_owner == 0:
		new_position = _battle_scene.player_lane_spaces[_lane_space + 1].find_node("CenterPoint").global_position
	else:
		new_position = _battle_scene.enemy_lane_spaces[_lane_space + 1].find_node("CenterPoint").global_position
	
	# Move to new position
	yield(slide_to_position(new_position, 0.2), "completed")
	_ally_lane[_lane_space] = null
	_lane_space = new_space
	
	# Check if card reached end space
	if new_space == end_space:
		emit_signal("scored", _card_owner, value)
		queue_free()
	else:
		_ally_lane[new_space] = self
		find_targets()


func perform_post_travel():
	yield(get_tree(), "idle_frame")


func take_damage(attacker, dmg):
	match card_id:
		"":
			pass
		_:
			health -= dmg
			health = max(0, health)
			animate("shake")
	update_stats()
	
	# die
	if health == 0:
		queue_free()
		_ally_lane[_lane_space] = null
		return true
	return false