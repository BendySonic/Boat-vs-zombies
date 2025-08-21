extends Sprite2D


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.get_parent() is Block and is_inside_tree():
		area.get_parent().heal.emit()
		queue_free()
