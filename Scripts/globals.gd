extends Node2D

# Placing these here allows the claw.gd and item.gd scripts to communicate
var PIN_JOINT : PinJoint2D
var CLAW : StaticBody2D

# The currently held item
var grabbed_item : RigidBody2D

# Player's score
var points = 0
var score_label = null

func update_player_score(value: int) -> void:
	points += value
	if score_label:
		score_label.text = "Score: %d" % points

# Attach the grabbed item to the pin joint to allow it to swing while held
func attach_pin_joint(node: Node2D) -> void:
	PIN_JOINT.node_b = node.get_path()

# Reset grabbed_item and pin joint when the player releases the item 
func release_grabbed_item() -> void:
	if grabbed_item:
		grabbed_item.released_by_claw()
		grabbed_item = null
		PIN_JOINT.node_b = NodePath()
