extends Control

@onready var score_label = $Score
@onready var level_label = $Level
@onready var energy_bar = $EnergyBar
@onready var requirements_label = $Level_Requirements/Requirements_Label

var animating_bar = false

# How fast the player loses energy
func _ready() -> void:
	# Set Globals variables
	Globals.HUD = self
	
	level_label.text = "Level: %d" % Globals.level
	score_label.text = "Score: %d" % Globals.score
	
	energy_bar.value = Globals.energy

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
	$Level_Requirements.size.y = requirements_label.get_minimum_size().y + 5

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

# Animate score change
func update_score_label(prev_score) -> void:
	#score_label.text = "Score: %d" % Globals.score
	var tween = create_tween() #.set_parallel(true)
	
	tween.tween_property(
		score_label,
		"modulate",
		Color.LIME_GREEN,
		0.1
	)
	
	tween.tween_property(
		score_label,
		"scale",
		Vector2(1.25, 1.25),
		0.1
	)
	
	tween.tween_method(
		func(score):
			score_label.text = "Score: %d" % score,
		prev_score,
		Globals.score,
		0.25
	).set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(
		score_label,
		"modulate",
		Color.WHITE,
		0.1
	)
	
	tween.tween_property(
		score_label,
		"scale",
		Vector2(1, 1),
		0.11
	)
