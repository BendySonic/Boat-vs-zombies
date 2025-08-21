extends Node2D

signal loaded(blocks: int)
signal block_group_updated
signal died

var block_group: Array
var blocks: Array

var reserved_blocks: Array

var is_ready := false

var ice_mass := 1

func play():
	create_block_groups()
	is_ready = true

func create_block_groups():
	block_group = []
	for block in blocks:
		block.is_block_connected = false
	fill_block_group(Data.player, block_group)
	for block in blocks:
		if not block_group.has(block):
			block.queue_free()
	create_parts()
	block_group_updated.emit()

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
		if child is RigidBody2D:
			for block in child.get_children():
				block.last_global_transform = block.global_transform
				child.remove_child(block)
			remove_child(child)
			child.queue_free()
			continue
		else:
			remove_child(child)
	
	for block in block_group:
		add_child(block)

	var rigid_body = RigidBody2D.new()
	rigid_body.gravity_scale = 0
	rigid_body.mass = 1 * ice_mass
	add_child(rigid_body)
	for block in block_group:
		block.reparent(rigid_body, true)
		if not block.last_global_transform == null:
			block.global_transform = block.last_global_transform
		
			block.rigid_body = rigid_body
			block.is_ready = true

func save_blocks():
	update_blocks()
	return_reserved_blocks()
	for x in range(0, 14):
		for y in range(0, 14):
			var block = find_block(Vector2(x, y))
			if block == null:
				Data.blocks[x][y] = null
				continue
			if not block.get_parent() == null:
				block.is_ready = false
				block.get_parent().remove_child(block)
			Data.blocks[x][y] = block

func load_blocks():
	var block_count := 0
	for x in range(0, 14):
		for y in range(0, 14):
			var block: Block = Data.blocks[x][y]
			if block == null:
				continue
			add_child(block)
			block.reload(self)
			loaded.connect(block._on_ship_loaded)
			block_group_updated.connect(block._on_block_group_updated)
			block.block_destroyed.connect(_on_block_destroyed)
			block.block_hit.connect(_on_block_hit)
			block.heal.connect(_on_heal)
			block_count += 1
	update_blocks()
	loaded.emit(block_count)
	

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

func return_reserved_blocks():
	for block in reserved_blocks:
		blocks.push_back(block)
	reserved_blocks = []

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
	var block_parent = block.get_parent()
	if not block_parent == null:
		block.get_parent().remove_child(block)
	reserved_blocks.push_back(block)
	
	if block is Player:
		var camera = block.get_camera()
		var camera_position = camera.global_position
		camera.reparent(get_parent())
		camera.global_position = camera_position
		died.emit()
	elif is_instance_valid(Data.player):
		update_blocks()
		create_block_groups()
	
	

func _on_block_hit(enemy):
	if enemy is Ice:
		if ice_mass == 1:
			ice_mass = 5
			modulate = Color(0.718, 0.9, 1)
			var child = get_child(0)
			if not child == null:
				if child is RigidBody2D:
					for rigid_body in get_children():
						rigid_body.mass *= ice_mass
					await get_tree().create_timer(4).timeout
					for rigid_body in get_children():
						rigid_body.mass /= ice_mass
					ice_mass = 1
					modulate = Color(1, 1, 1)

func _on_heal():
	if is_inside_tree():
		modulate = Color(0, 0.988, 0.456)
		await get_tree().create_timer(1).timeout
		modulate = Color(1, 1, 1)
	update_blocks()
	for block in blocks:
		block.strength += 1
	
func is_have_player():
	for child in get_children():
		if child is Player:
			return true
	return false
