extends Node2D

# Placing these here allows the claw.gd and item.gd scripts to communicate
var PIN_JOINT : PinJoint2D
var CLAW : StaticBody2D

# The currently held item
var grabbed_item : RigidBody2D

var energy

var points = 0
var score_label = null

var HUD
var level = 1
var required_level_items
var current_captured_items = {
	"screw": 0,
	"battery": 0,
	"gear": 0,
	"broken": 0
}

# Update player energy, score, score label, items captured
func player_captured_item(points_value: int, energy_value: int, item_type: String) -> void:
	points += points_value
	energy += energy_value
	if score_label:
		score_label.text = "Score: %d" % points
	
	current_captured_items[item_type] += 1
	
	# Update HUD to show new values
	HUD.update_requirements_list(required_level_items)
	
	# Check if the level is complete
	if check_if_level_complete():
		print("Transition to next level")

# Check if the player has captured all the required items
func check_if_level_complete() -> bool:
	for item in required_level_items:
		if current_captured_items[item] != required_level_items[item]:
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
