extends Node2D

@onready var level_floor = $Floor
@onready var HUD = $HUD_Container/HUD
@onready var game_over_UI = $HUD_Container/GameOverUI
@onready var level_count_label = $HUD_Container/Transition/LevelCount
@onready var transition_screen = $HUD_Container/Transition

@onready var item_spawn_area = $ItemSpawnArea
@onready var item_spawn_area_shape = $ItemSpawnArea/ItemSpawnAreaShape
@onready var item_manager = $ItemSpawnArea/ItemManager

@onready var preloaded_items = {
	"screw": preload("res://Scenes/Items/screw_item.tscn"),
	"battery": preload("res://Scenes/Items/battery_item.tscn"),
	"gear": preload("res://Scenes/Items/gear_item.tscn"),
	"crate": preload("res://Scenes/Items/crate_item.tscn"),
	"golden gear": preload("res://Scenes/Items/golden_gear_item.tscn"),
	"hex nut": preload("res://Scenes/Items/hex_nut_item.tscn"),
	"wheel": preload("res://Scenes/Items/wheel_item.tscn"),
	"energy bar": preload("res://Scenes/Items/energy_bar.tscn"),
	"bomb": preload("res://Scenes/Items/bomb_item.tscn"),
}

var SPAWN_DELAY = 0.15

# Track which items NEED to spawn to meet level requirements
var required_items_to_spawn = []

func _ready() -> void:
	Globals.connect("next_level", _next_level_handler)
	Globals.connect("game_over", _game_over_handler)
	#level_floor.rotate(0.43)
	game_over_UI.visible = false
	# Update the level count and play transition effect
	level_count_label.text = "Level: %d" % Globals.level
	transition_screen.visible = true
	level_count_label.modulate = "ffffff00"
	await fade_in_out(level_count_label, false, 1)
	#await get_tree().create_timer(1).timeout
	await fade_in_out(transition_screen, true, 1)
	
	# Generate the level requirements and spawn item
	generate_level_requirements()
	spawn_random_items()

# Reset the level when this script receives the "next_level" signal
func _next_level_handler():
	level_count_label.visible = false
	transition_screen.visible = true
	await fade_in_out(transition_screen, false, 1)
	get_tree().reload_current_scene()

# Fade in the "Game Over" UI
func _game_over_handler(level, score) -> void:
	$HUD_Container/GameOverUI/VBoxContainer/FinalLevel.text = "You reached level %d" % level
	$HUD_Container/GameOverUI/VBoxContainer/FinalScore.text = "Final Score: %d" % score
	game_over_UI.modulate = "ffffff00"
	game_over_UI.visible = true
	fade_in_out(game_over_UI, false, 1.5)

# Generate a random set of required items to beat the level
func generate_level_requirements() -> void:
	var random_item
	
	# Scale the required items by the level value
	for i in (Globals.MIN_REQUIRED_ITEMS + Globals.level):
		random_item = preloaded_items.keys().pick_random()
		# Avoid picking a bomb / energy bar as a required item
		while random_item == "bomb" or random_item == "energy bar":
			random_item = preloaded_items.keys().pick_random()
		# Increment the number required for the specific item
		Globals.required_level_items[random_item] += 1
		required_items_to_spawn.append(random_item)
	
	# Tell HUD to update the requirements label
	HUD.update_requirements_list()

# Spawn items random within the ItemSpawnAreaShape node
func spawn_random_items():
	var random_pos
	var random_item
	var new_item
	
	# First spawn all the items required to beat the level
	for item in required_items_to_spawn:
		random_pos = get_random_spawn()
		new_item = preloaded_items[item].instantiate()
		new_item.position = random_pos
		item_manager.add_child(new_item)
		new_item.scale = Vector2(1.25, 1.25)
		await get_tree().create_timer(SPAWN_DELAY).timeout
	
	# Then spawn the other randomized items
	for i in (Globals.MIN_ITEMS_SPAWN + Globals.level - len(required_items_to_spawn)):
		random_pos = get_random_spawn()
		random_item = preloaded_items.keys().pick_random()
		new_item = preloaded_items[random_item].instantiate()
		new_item.position = random_pos
		
		item_manager.add_child(new_item)
		new_item.scale = Vector2(1.25, 1.25)
		await get_tree().create_timer(SPAWN_DELAY).timeout
	
	Globals.game_state = "READY"

# Return a random spawn location within the bounds of the platform
func get_random_spawn() -> Vector2:
	var shape = item_spawn_area_shape.shape.size / 2.0
	var pos = Vector2(
		randf_range(
			item_spawn_area_shape.position.x - shape.x, 
			item_spawn_area_shape.position.x + shape.x),
		randf_range(
			item_spawn_area_shape.position.y - shape.y, 
			item_spawn_area_shape.position.y + shape.y)
		)
	return pos 

# Fade effect for entering / leaving the scene
func fade_in_out(fade_item: Control, fade_in: bool, duration: float) -> bool:
	var tween = create_tween()
	if fade_in:
		tween.tween_property(fade_item, "modulate:a", 0, duration)
	else:
		tween.tween_property(fade_item, "modulate:a", 1, duration)
	await tween.finished
	return true

# WIP
func _on_main_menu_button_pressed() -> void:
	print("Main Menu Button Pressed")
