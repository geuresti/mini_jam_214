extends Node2D

var PIN_JOINT : PinJoint2D
var CLAW : StaticBody2D

var grabbed_item : RigidBody2D

func attach_pin_joint(node: Node2D):
	PIN_JOINT.node_b = node.get_path()

func release_grabbed_item():
	grabbed_item.released_by_claw()
	grabbed_item = null
	PIN_JOINT.node_b = NodePath()
