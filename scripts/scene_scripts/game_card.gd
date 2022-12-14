class_name GameCard
extends Node2D
# A card as it exists in battle.
# Includes logic for attacking, taking damage, moving, and animating.


signal scored(team, value)

const THEME_STATS = preload("res://assets/themes/theme_cd_stats.tres")
const THEME_STATS_DIGITS = preload("res://assets/themes/theme_cd_stats_digits.tres")

export var distance_to_target: float setget set_distance_to_target
export var snd_deal_a: AudioStream
export var snd_deal_b: AudioStream
export var snd_attack: AudioStream
export (Array, AudioStream) var snd_move
export var snd_gold: AudioStream

# Card stats
var card_id: String
var card_name: String
var card_description: String
var power: int
var health: int
var value: int
var status_flags = 0

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
var _target_position: Vector2


# Builtin functions


func _init():
	_card_owner = 1


func _ready():
	_targets = []
	_target_position = global_position
	update_stats()
	find_node("Name").text = card_name
	_battle_scene = get_tree().current_scene
	if _card_owner == 0:
		_ally_lane = _battle_scene.player_lane_cards
		_enemy_lane = _battle_scene.enemy_lane_cards
	else:
		_ally_lane = _battle_scene.enemy_lane_cards
		_enemy_lane = _battle_scene.player_lane_cards
	if card_name.length() > 12:
		var name_scale = min(1.0, 12.0 / card_name.length())
		find_node("Name").rect_scale = Vector2(name_scale, name_scale)


func init (id: String):
	var card_data = CardDictionary.get_card_data(id)
	
	self.card_id = id
	self.card_name = card_data.name
	self.card_description = card_data.description
	
	if card_data.image_portrait != "":
		$CardVisual/Art.texture = load("res://assets/sprites/cards/" + card_data.image_portrait)
	
	self.power = card_data.power
	self.value = card_data.value
	self.health = card_data.health
	
	return self


# Setget functions


func set_distance_to_target(value):
	var angle = (_target_position - global_position).normalized()
	$CardVisual.position = angle * value


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


func slide_to_position(pos, time, ignore_timescale = false):
	if !ignore_timescale:
		time = time / SettingsController.graphics_animation_timescale
	$Tween.interpolate_property(self, "global_position", global_position, pos, time, Tween.TRANS_LINEAR)
	$Tween.start()
	yield($Tween, "tween_completed")


func select():
	pass


func deselect():
	pass


# Gameplay functions


func find_targets():
	_targets.clear()
	
	var opposite_space = _enemy_lane.size() - _lane_space - 1
	match card_id:
		"MEDIEVAL_ARCHER":
			var space = opposite_space
			while space >= 0:
				if _enemy_lane[space]:
					_targets.append(space)
					break
				space -= 1
		_:
			_targets.append(opposite_space)


func attack():
	if power == 0:
		yield(get_tree(), "idle_frame")
		return
	
	yield(perform_pre_attack(), "completed")
	yield(perform_attack(), "completed")
	yield(perform_post_attack(), "completed")
	update_stats()
	if health == 0:
		queue_free()
		_ally_lane[_lane_space] = null


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
	find_targets()
	yield(get_tree(), "idle_frame")


func perform_attack():
	for t in _targets:
		if _enemy_lane[t]:
			_target_position = _enemy_lane[t].global_position
			$AnimationPlayer.play(
				"attack_start",
				-1,
				SettingsController.graphics_animation_timescale
			)
			yield($AnimationPlayer, "animation_finished")
			
			match card_id:
				"MEDIEVAL_THIEF":
					var v = _enemy_lane[t].value
					if v > 0:
						_enemy_lane[t].value = v - 1
						value += 1
				"GREEK_BOSS_MIDAS_HAND":
					_enemy_lane[t].apply_status("STATUS_GOLD_STATUE")
			
			play_sound("attack")
			var opposing_card_killed = _enemy_lane[t].take_damage(self, power)
			$AnimationPlayer.play(
				"attack_end",
				-1,
				SettingsController.graphics_animation_timescale
			)
			yield($AnimationPlayer, "animation_finished")
			_target_position = global_position
			
			match card_id:
				"MEDIEVAL_BOSS_LANCE":
					health = 0
					break
	yield(get_tree(), "idle_frame")


func perform_post_attack():
	yield(get_tree(), "idle_frame")


func perform_pre_travel():
	yield(get_tree(), "idle_frame")


func perform_travel():
	# Check STATUS_GOLD_STATUE
	if (status_flags & (1 << 0) != 0):
		var can_move = false
		var i = _lane_space - 1
		while i >= 0:
			if !_ally_lane[i]:
				break
			if _ally_lane[i].status_flags & (1 << 0) == 0:
				can_move = true
				break
			i -= 1
		
		if !can_move:
			yield(get_tree(), "idle_frame")
			return
	
	
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
	play_sound("move")
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
	match card_id:
		"MEDIEVAL_BOSS_HEART":
			health += 1
			power = health
			update_stats()
	yield(get_tree(), "idle_frame")


func take_damage(attacker, dmg):
	match card_id:
		"MEDIEVAL_BOSS_HEART":
			health -= dmg
			health = max(0, health)
			power = health
			$AnimationPlayer.play(
				"shake",
				-1,
				SettingsController.graphics_animation_timescale
			)
		_:
			health -= dmg
			health = max(0, health)
			$AnimationPlayer.play(
				"shake",
				-1,
				SettingsController.graphics_animation_timescale
			)
	update_stats()
	
	# die
	if health == 0:
		queue_free()
		_ally_lane[_lane_space] = null
		return true
	return false


func apply_status(status: String):
	match status:
		"STATUS_GOLD_STATUE":
			if (status_flags & (1 << 0) != 0):
				return
			status_flags = status_flags | (1 << 0)
			power = 0
			value += 2
			$CardVisual.modulate = Color(1.0, 0.8, 0.4)
			play_sound("gold")


func _on_board_state_changed():
	var opposite_space = _enemy_lane.size() - _lane_space - 1
	match card_id:
		"MEDIEVAL_BOSS_EYE":
			if _enemy_lane[opposite_space]:
				power = _enemy_lane[opposite_space].power
			else:
				power = 0
			update_stats()


func play_sound(sound):
	match sound:
		"deal_a":
			$Sfx.stream = snd_deal_a
		"deal_b":
			$Sfx.stream = snd_deal_b
		"attack":
			$Sfx.stream = snd_attack
		"move":
			$Sfx.stream = snd_move[int(rand_range(0.0, snd_move.size()))]
		"gold":
			$Sfx.stream = snd_gold
	$Sfx.play()
