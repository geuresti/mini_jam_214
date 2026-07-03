extends RigidBody2D

@onready var grab_box = $GrabBox
var is_grabbed : bool = false
var follow_claw : bool = false

func _process(delta: float) -> void:
	if follow_claw:
		#global_position.x = Globals.CLAW.global_position.x
		global_position.y = Globals.CLAW.global_position.y + 30

func _on_grab_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("Claw") and not is_grabbed and not Globals.grabbed_item:
		print("Item detected claw")
		is_grabbed = true
		follow_claw = true
		Globals.grabbed_item = self

func connect_to_joint():
	follow_claw = false
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	Globals.attach_pin_joint(self)

func released_by_claw():
	is_grabbed = false
