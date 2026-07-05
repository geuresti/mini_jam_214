extends Node2D

signal next_level

# Placing these here allows the claw.gd and item.gd scripts to communicate
var PIN_JOINT : PinJoint2D
var CLAW : StaticBody2D

# (LOADING, READY)
var game_state = "LOADING"

# The currently held item
var grabbed_item : RigidBody2D

var max_energy = 100
var energy
var drain_rate = 1.0
var GRAB_ENERGY_COST = -8

var points = 0
var score_label = null

var HUD
var level = 1

var required_level_items
var current_captured_items

func _ready() -> void:
	reset_required_level_items()
	reset_current_captured_items()
	energy = max_energy

func _process(_delta) -> void:
	if energy <= 0:
		print("You lose!!!!")

# Update player energy, score, score label, items captured
func player_captured_item(points_value: int, energy_value: int, item_type: String) -> void:
	points += points_value
	
	# Instruct the HUD to update energy and the energy progress bar
	update_energy_helper(energy_value)
	
	# Update the score label to show the new point value
	update_score_label()
	
	# Increment captured items
	current_captured_items[item_type] += 1
	
	# Update HUD to show new values
	HUD.update_requirements_list()
	
	# Check if the level is complete
	if check_if_level_complete():
		await get_tree().create_timer(1).timeout
		next_level_transition()

func update_score_label() -> void:
	if score_label:
		score_label.text = "Score: %d" % points

# Check if the player has captured all the required items
func check_if_level_complete() -> bool:
	for item in required_level_items:
		if current_captured_items[item] < required_level_items[item]:
			return false
	return true

# Attach the grabbed item to the pin joint to allow it to swing while held
func attach_pin_joint(node: Node2D) -> void:
	PIN_JOINT.node_b = node.get_path()

# Reset grabbed_item and pin joint when the player releases the item 
func release_grabbed_item() -> void:
	if grabbed_item:
		grabbed_item.released_by_claw()
		grabbed_item = null
		PIN_JOINT.node_b = NodePath()

# Transition to the next level
func next_level_transition() -> void:
	level += 1
	energy = max_energy
	drain_rate += 0.25
	
	# This signals the level.gd script to trigger a level reset function
	emit_signal("next_level") 
	
	# Reset required and captured items 
	reset_required_level_items()
	reset_current_captured_items()

func reset_required_level_items() -> void:
	required_level_items = {
		"screw": 0,
		"battery": 0,
		"gear": 0,
		"crate": 0,
		"golden gear": 0,
		"hex nut": 0,
		"wheel": 0
	}

func reset_current_captured_items() -> void:
	current_captured_items = {
		"screw": 0,
		"battery": 0,
		"gear": 0,
		"bomb": 0,
		"crate": 0,
		"golden gear": 0,
		"energy bar": 0,
		"hex nut": 0,
		"wheel": 0
	}

# Instruct the HUD to update energy and the energy progress bar
func update_energy_helper(energy) -> void: HUD.animate_energy_change(energy)
