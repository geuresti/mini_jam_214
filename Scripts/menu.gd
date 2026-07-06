extends Control

@onready var background_music = $BackgroundMusic
@onready var button_press = $ButtonPress
@onready var animation_player = $SpriteContainer/AnimationPlayer

var button_delay = 0.2

func _ready() -> void:
	fade_in_background_music()
	animation_player.play("menu_animation")

func _on_play_button_pressed() -> void:
	button_press.play()
	await get_tree().create_timer(button_delay).timeout
	get_tree().change_scene_to_file("res://Scenes/level.tscn")

func _on_exit_button_pressed() -> void:
	button_press.play()
	await get_tree().create_timer(button_delay).timeout
	get_tree().quit()

# Fade the music in over small duration
func fade_in_background_music() -> void:
	# Start volume
	background_music.volume_db = -30
	background_music.play()
	var tween = create_tween()
	# End at -20 decibles over 4 seconds
	tween.tween_property(
		background_music,
		"volume_db",
		-20,
		4
	)
