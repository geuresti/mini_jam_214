extends CharacterBody2D

@export var move_speed = 250
@onready var claw_part = $ClawPart
@onready var claw_hit_box = $ClawPart/ClawHitBox
@onready var pin_joint = $ClawPart/ClawCollisionShape/PinJoint2D

# These bools help gate player input and track logic during a grab
var is_grabbing = false
var is_lowering = false
var is_retracting = false
var holding_item = false
var is_releasing = false

var GRAB_COOLDOWN = 1
var CLAW_GRAB_SPEED = 10

# Set the Globals variables
func _ready():
	Globals.PIN_JOINT = pin_joint
	Globals.CLAW = claw_part

func _physics_process(_delta: float) -> void:
	# If the claw is grabbing or releasing, disable the hit box
	# this prevents items from getting stuck floating in the air
	if holding_item or is_releasing:
		claw_hit_box.monitoring = false
	else:
		claw_hit_box.monitoring = true
	
	# If the claw is not current grabbing allow input
	if not is_grabbing:
		# If the claw is holding an item, release it
		# If the claw is empty, then perform a grab
		if Input.is_action_just_pressed("activate"):
			if not is_releasing:
				if holding_item:
					claw_release()
				else:
					claw_grab()
		# Claw left / right movement
		else:
			get_input()
			move_and_slide()

# Up and Down are unused (Need to fix)
func get_input() -> void:
	var input_dir = Input.get_vector("left", "right", "ui_up", "ui_down")
	velocity = input_dir * move_speed

# Release the grabbed item
func claw_release() -> void:
	is_releasing = true
	Globals.release_grabbed_item()
	await get_tree().create_timer(GRAB_COOLDOWN).timeout
	holding_item = false
	is_releasing = false

# Perform a grab
func claw_grab() -> void:
	is_grabbing = true
	await lower_claw()
	await retract_claw()
	# Reset claw position
	claw_part.position.y = 0
	is_grabbing = false

# Lower until the claw hits an item or the floor
func lower_claw() -> bool:
	is_lowering = true
	while is_lowering and claw_part.position.y < 640: # Prevent infinite grab
		claw_part.position.y += CLAW_GRAB_SPEED
		await get_tree().process_frame
	# Pause at the bottom for 0.5 seconds before retracting
	await get_tree().create_timer(0.5).timeout
	return true

# Retract the claw and attach the grabbed item
func retract_claw() -> bool:
	is_retracting = true
	while claw_part.position.y > 0:
		claw_part.position.y -= CLAW_GRAB_SPEED
		await get_tree().process_frame
	
	# Check if there's a grabbed item
	if Globals.grabbed_item:
		# Connect item to pinjoint AFTER the claw has retracted fully
		Globals.grabbed_item.connect_to_joint()
	
	is_retracting = false
	return true

# An area overlapped with the claw's hitbox (either an Item or a Strcture)
func _on_claw_hit_box_area_entered(area: Area2D) -> void:
	if not holding_item:
		if area.is_in_group("Item"):
			holding_item = true
		is_lowering = false
		
		#if area.is_in_group("Structure"):
			#print("Claw contacted a structure")
