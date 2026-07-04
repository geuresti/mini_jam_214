extends Node2D

@onready var floor = $Floor
@onready var HUD = $HUD

# Testing platform manipulation
#func _ready() -> void:
#	await get_tree().create_timer(1).timeout
#	floor.rotate(0.43)

# How many items will fill the claw machine at minium
var MIN_ITEMS_SPAWN = 8

# How many items are required to pass the level 
# (this will scale based on Globals.level value)
var min_required_items = 3

var items = ["screw", "battery", "gear", "broken"]

var required_items = {
	"screw": 0,
	"battery": 0,
	"gear": 0,
	"broken": 0
}

func _ready() -> void:
	generate_level_requirements()

# Generate a random set of required items to beat the level
func generate_level_requirements() -> void:
	for i in min_required_items:
		required_items[items.pick_random()] += 1
	
	# Update Globals var
	Globals.required_level_items = required_items
		
	# Tell HUD to update the requirements label
	HUD.update_requirements_list(required_items)
