extends Node2D

var detected_item : Area2D = null

# An item entered the score zone area
func _on_score_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Item"):
		detected_item = area
		
		# If the item has been in the bucket after a small delay, score it
		# This prevents items from being scored if they bounce out
		await get_tree().create_timer(0.25).timeout
		
		if is_instance_valid(detected_item):
			detected_item.get_parent().captured()

# If the item bounces out of the area, update detected_item
func _on_score_zone_area_exited(area: Area2D) -> void:
	if area.is_in_group("Item"):
		if area == detected_item:
			detected_item = null
