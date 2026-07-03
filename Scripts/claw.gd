extends CharacterBody2D

@export var move_speed = 250
@onready var claw_part = $ClawPart
@onready var claw_hit_box = $ClawPart/ClawHitBox
@onready var pin_joint = $ClawPart/ClawCollisionShape/PinJoint2D

var is_grabbing = false
var is_lowering = false
var is_retracting = false
var holding_item = false
var is_releasing = false

func _ready():
	Globals.PIN_JOINT = pin_joint
	Globals.CLAW = claw_part

func _physics_process(delta: float) -> void:
	# If the claw is not current grabbing, allow grab / release action
	if not is_grabbing and not is_releasing:
		if Input.is_action_just_pressed("grab"):
			if not holding_item:
				claw_grab()
			else:
				claw_release()
		else:
			# Claw movement
			get_input()
			move_and_slide()

# Up and Down are unused
func get_input():
	var input_dir = Input.get_vector("left", "right", "ui_up", "ui_down")
	velocity = input_dir * move_speed

func claw_release():
	is_releasing = true
	Globals.release_grabbed_item()
	# One second cooldown on grab
	await get_tree().create_timer(1).timeout
	holding_item = false
	is_releasing = false

func claw_grab():
	is_grabbing = true
	await lower_claw()
	await retract_claw()
	# Reset claw position
	claw_part.position.y = 0
	is_grabbing = false

var claw_grab_speed = 10

func lower_claw():
	is_lowering = true
	while is_lowering and claw_part.position.y < 640: # arbitray limit
		claw_part.position.y += claw_grab_speed
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	return true

func retract_claw():
	is_retracting = true
	while is_retracting:
		claw_part.position.y -= claw_grab_speed
		await get_tree().process_frame
		if claw_part.position.y <= 0:
			break
	await get_tree().create_timer(0.5).timeout
	
	# Check if there's a grabbed item
	if Globals.grabbed_item:
		# Connect item to pinjoint AFTER the claw has retracted
		Globals.grabbed_item.connect_to_joint()
	
	is_retracting = false
	return true

func _on_claw_hit_box_area_entered(area: Area2D) -> void:
	if not holding_item:
		if area.is_in_group("Item"):
			print("Claw contacted an item")
			holding_item = true
		is_lowering = false
		
		#if area.is_in_group("Structure"):
			#print("Claw contacted a structure")
