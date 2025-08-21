extends TileMap


func _draw() -> void:
	#draw_rect(
	#	Rect2(Vector2(0, 0), tile_set.tile_size * 15),
	#	Color(0.05, 0.05, 0.05),
	#	true
	#)
	for x in range(1, 15):
		draw_line(
				Vector2(x * tile_set.tile_size.x, 0),
				Vector2(x * tile_set.tile_size.x, tile_set.tile_size.y * 15),
				Color(0.12, 0.12, 0.12), 
				2.0
			)
	for y in range(1, 15):
		draw_line(
				Vector2(0, y * tile_set.tile_size.y),
				Vector2(tile_set.tile_size.x * 15, y * tile_set.tile_size.y),
				Color(0.12, 0.12, 0.12), 
				2.0
			)
