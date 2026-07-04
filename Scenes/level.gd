extends Node2D

@onready var floor = $Floor

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	floor.rotate(0.43)
