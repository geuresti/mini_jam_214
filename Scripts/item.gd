extends RigidBody2D

# The hitbox for the claw to detect
@onready var grab_box = $GrabBox

# This variables will vary by sub class (Ex: gear, screw, etc.)
@export var points = 5
@export var energy = 0
@export var item_type = "item"
 
var is_grabbed : bool = false
var follow_claw : bool = false

func _ready() -> void:
	$Sprite2D.scale = Vector2(2, 2)
	$GrabBox.scale = Vector2(2, 2)
	$PhysicsCollisionShape.scale = Vector2(2, 2)

# Follow the claw as it retracts upwards after a grab
func _process(_delta: float) -> void:
	if follow_claw:
		global_position.y = Globals.CLAW.global_position.y + 30

# The claw and grab_box overlap
func _on_grab_box_area_entered(area: Area2D) -> void:
	# Check that the overlapping area is in group "Claw"
	# and that it is not already grabbed (is_grabbed)
	# and that the claw isn't already holding an item (Globals.grabbed_item)
	if area.is_in_group("Claw") and not is_grabbed and not Globals.grabbed_item:
		is_grabbed = true
		follow_claw = true
		Globals.grabbed_item = self

# Stop following the claw and instead attach the pin joint to itself
func connect_to_joint() -> void:
	follow_claw = false
	# Reset velocities to prevent major swinging during attachment
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	Globals.attach_pin_joint(self)

# Toggle is_grabbed (this is called by Globals.gd)
func released_by_claw() -> void:
	is_grabbed = false

# Triggered when an item makes it into the bucket (this is called by bucket.gd)
func captured() -> void:
	Globals.player_captured_item(points, energy, item_type)
	queue_free()
