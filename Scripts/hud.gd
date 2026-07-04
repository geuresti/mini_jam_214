extends Control

@onready var score_label = $Score
@onready var energy_bar = $EnergyBar
@onready var requirements_label = $Level_Requirements/Label

# How fast the player loses energy
var DRAIN_RATE = 2

func _ready() -> void:
	# Set Globals variables
	Globals.HUD = self
	Globals.score_label = score_label
	Globals.energy = 100
	energy_bar.value = Globals.energy

# Update energy bar
func _process(delta: float) -> void:
	Globals.energy -= max(DRAIN_RATE * delta, 0.0)
	energy_bar.value = Globals.energy

# Update the label to read in the format "Item: 0/2"
func update_requirements_list(requirements_dict) -> void:
	var requirements_text = ""
	for key in requirements_dict:
		var value = requirements_dict[key]
		if value > 0:
			requirements_text += str(key) + ": " + str(Globals.current_captured_items[key]) + " / " + str(value) + "\n"
	requirements_label.text = requirements_text
