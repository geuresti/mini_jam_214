extends Node2D

var detected_item : Area2D = null

# An item entered the score zone area
func _on_score_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("Item"):
		detected_item = area
		
		# If the item has been in the bucket for one second, score it
		# This prevents items from being scored if they bounce out
		await get_tree().create_timer(1).timeout
		
		if area == detected_item:
			# Call the item's captured() function
			detected_item.get_parent().captured()
			detected_item = null

# If the item bounces out of the area, update detected_item
func _on_score_zone_area_exited(area: Area2D) -> void:
	if area.is_in_group("Item"):
		if area == detected_item:
			detected_item = null
