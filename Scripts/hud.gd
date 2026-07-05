extends Control

@onready var score_label = $Score
@onready var level_label = $Level
@onready var energy_bar = $EnergyBar
@onready var requirements_label = $Level_Requirements/Label

# How fast the player loses energy
func _ready() -> void:
	# Set Globals variables
	Globals.HUD = self
	Globals.score_label = score_label
	
	level_label.text = "Level: %d" % Globals.level
	
	Globals.update_score_label()
	energy_bar.value = Globals.energy

var animating_bar = false

# Update energy bar
func _process(delta: float) -> void:
	if Globals.game_state == "READY":
		# Pause the natural drain when the bar is playing an animation
		if not animating_bar:
			Globals.energy -= max((Globals.drain_rate) * delta, 0.0)
			energy_bar.value = Globals.energy

# Update the label to read in the format "Item: 0/2"
func update_requirements_list() -> void:
	var requirements_text = ""
	for key in Globals.required_level_items:
		var value = Globals.required_level_items[key]
		if value > 0:
			requirements_text += str(key) + ": " + str(Globals.current_captured_items[key]) + " / " + str(value) + "\n"
	requirements_label.text = requirements_text

# Animate significant energy adjustment
func animate_energy_change(value: int) -> void:
	animating_bar = true
	var tween = create_tween()
	# Update the energy to the target value before animating
	Globals.energy += value
	await tween.tween_property(
		energy_bar, "value", Globals.energy, 0.5
	).set_trans(Tween.TRANS_CUBIC).finished
	animating_bar = false
