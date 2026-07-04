extends Node2D

@onready var level_floor = $Floor
@onready var HUD = $HUD_Container/HUD
@onready var scene_transition = $HUD_Container/SceneTransition

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

# Track which items NEED to spawn to meet level requirements
var required_items_to_spawn = []

# How many items will fill the claw machine at minium
var MIN_ITEMS_SPAWN = 8

# How many items are required to pass the level minimum
var min_required_items = 2

func _ready() -> void:
	#level_floor.rotate(0.43)
	scene_transition.visible = true
	await fade_in_out(true)
	generate_level_requirements()
	spawn_random_items()

# Generate a random set of required items to beat the level
func generate_level_requirements() -> void:
	var random_item
	
	# Scale the required items by the level value
	for i in (min_required_items + Globals.level):
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
		#new_item.scale = Vector2(1.5, 1.5)
		await get_tree().create_timer(0.25).timeout
	
	# Then spawn the other randomized items
	for i in (MIN_ITEMS_SPAWN + Globals.level - len(required_items_to_spawn)):
		random_pos = get_random_spawn()
		random_item = preloaded_items.keys().pick_random()
		new_item = preloaded_items[random_item].instantiate()
		new_item.position = random_pos
		
		item_manager.add_child(new_item)
		#new_item.scale = Vector2(1.5, 1.5)
		await get_tree().create_timer(0.25).timeout
	
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
func fade_in_out(fade_in : bool) -> bool:
	var tween = create_tween()
	if fade_in:
		tween.tween_property(scene_transition, "modulate:a", 0, 0.5)
	else:
		tween.tween_property(scene_transition, "modulate:a", 1, 0.5)
	await tween.finished
	return true
