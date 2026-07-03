extends Node2D

@onready var cursor_control = $CursorControl

func _process(_delta):
	cursor_control.global_position = get_global_mouse_position()
