extends Node2D

var block_groups: Array[Array]
var blocks: Array

func create_block_groups():
	block_groups = []
	for block in blocks:
		block.is_block_connected = false
	for block in blocks:
		if not block.is_block_connected:
			var block_group: Array
			fill_block_group(block, block_group)
			block_groups.push_back(block_group)
	create_parts()

func get_player():
	for block in blocks:
		if block.item.item_type.name == "player":
			return block

func fill_block_group(block, block_group):
	block_group.push_back(block)
	block.is_block_connected = true
	for side in block.connections:
		var side_block
		match side:
			1:
				side_block = find_block(block.map_pos + Vector2.UP)
			2:
				side_block = find_block(block.map_pos + Vector2.RIGHT)
			3:
				side_block = find_block(block.map_pos + Vector2.DOWN)
			4:
				side_block = find_block(block.map_pos + Vector2.LEFT)
		if not side_block == null:
			if not side_block.is_block_connected:
				fill_block_group(side_block, block_group)

func create_parts():
	var children = get_children()
	for child in children:
		print(child)
		if child is RigidBody2D:
			for block in child.get_children():
				block.last_global_transform = block.global_transform
				child.remove_child(block)
			remove_child(child)
			child.queue_free()
			continue
		else:
			remove_child(child)
	
	for block in blocks:
		add_child(block)
	
	for block_group in block_groups:
		var rigid_body = RigidBody2D.new()
		rigid_body.gravity_scale = 0
		rigid_body.mass = 1
		add_child(rigid_body)
		for block in block_group:
			block.reparent(rigid_body, true)
			if not block.last_global_transform == null:
				block.global_transform = block.last_global_transform
			
			block.is_play = true

func save_blocks():
	update_blocks()
	for x in range(0, 7):
		for y in range(0, 7):
			var block = find_block(Vector2(x, y))
			if block == null:
				Data.blocks[x][y] = null
				continue
			remove_child(block)
			Data.blocks[x][y] = block

func load_blocks():
	for x in range(0, 7):
		for y in range(0, 7):
			var block = Data.blocks[x][y]
			if block == null:
				continue
			add_child(block)
			block.block_destroyed.connect(_on_block_destroyed)
	update_blocks()

func update_blocks():
	if get_child_count() == 0:
		return
	blocks = []
	var child = get_child(0)
	if not child == null:
		if child is RigidBody2D:
			for rigid_body in get_children():
				for block in rigid_body.get_children():
					blocks.push_back(block)
		elif child is CollisionShape2D:
			for block in get_children():
				blocks.push_back(block)

func find_block(map_pos):
	for block in blocks:
		if block.map_pos == map_pos:
			return block
	return null

func map_pos_to_local(map_pos: Vector2):
	var tile_size = Vector2(96, 96)
	return map_pos * tile_size + tile_size * 0.5

func local_pos_to_map(local_pos: Vector2):
	var tile_size = 96
	return (local_pos / tile_size).floor()

func _on_block_destroyed(block):
	print("OK")
	update_blocks()
	blocks.erase(block)
	create_block_groups()
	block.queue_free()
