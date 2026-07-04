extends Control

@onready var score_label = $Top_Row_UI/Score

# Allow the score_label to be accessed from Globals
func _ready() -> void:
	Globals.score_label = score_label
