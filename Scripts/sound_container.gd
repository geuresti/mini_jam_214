extends Node

# Receive signals in order to determine when to play sound effects

@onready var background_music = $BackgroundMusic
@onready var grab = $Grab
@onready var item_captured = $ItemCaptured
@onready var button_pressed = $ButtonPressed
@onready var claw_moving = $ClawMoving
@onready var item_spawn = $ItemSpawn

var claw_grab_sounds = [
	preload("res://Assets/Sounds/Grab_01.wav"),
	preload("res://Assets/Sounds/Grab_02.wav"),
	preload("res://Assets/Sounds/Grab_03.wav"),
	preload("res://Assets/Sounds/Grab_04.wav"),
]

func _ready() -> void:
	claw_moving.stream_paused = true
	fade_in_background_music()

# Fade the music in over small duration
func fade_in_background_music() -> void:
	# Start volume
	background_music.volume_db = -20
	background_music.play()
	var tween = create_tween()
	# End at -10 decibles over 3 seconds
	tween.tween_property(
		background_music,
		"volume_db",
		-20,
		3
	)

func _play_item_captured_sound() -> void:
	item_captured.play()

func _play_claw_grab_sound() -> void:
	grab.stream = claw_grab_sounds.pick_random()
	grab.play()

var claw_moving_audio_position = 0.0

func _play_claw_moving_sound() -> void: claw_moving.stream_paused = false

func _stop_claw_moving_sound() -> void: claw_moving.stream_paused = true

func _play_item_spawn_sound() -> void: item_spawn.play()

func _play_button_pressed_sound() -> void: button_pressed.play()
