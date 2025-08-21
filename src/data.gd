extends Node

# Storage of all game items
var items: Items = ResourceLoader.load("res://src/editor/item/items.tres")
# Storage of all user items
var user_item_stacks: Array[ItemStack]
# Items for build
var item_stacks: Array[ItemStack]

# Dynamic
var blocks: Array[Array]

# References
var player: Block

var high_score: int
var tutorial_1 := false
var tutorial_2 := false

var particles = preload("res://src/game/enemies/enemy.tres")

var invulnerability := false

func _ready():
	# TODO: Delete this
	user_item_stacks = [
		ItemStack.new(preload("res://src/editor/item/wood.tscn"), 12),
		ItemStack.new(preload("res://src/editor/item/wood_slope.tscn"), 5),
		ItemStack.new(preload("res://src/editor/item/engine.tscn"), 1),
		ItemStack.new(preload("res://src/editor/item/player.tscn"), 1),
	]
	load_user_data()
	# #
	clear_blocks()
	reload_items()

func add_item(block_scene: PackedScene, count: int):
	add_item_to_user(block_scene, count)
	add_item_to_build(block_scene, count)

func add_item_to_build(block_scene: PackedScene, count: int):
	for item_stack in item_stacks:
		if item_stack.block == block_scene:
			item_stack.count += count
			return
	item_stacks.push_back(ItemStack.new(block_scene, count))

func add_item_to_user(block_scene: PackedScene, count: int):
	for user_item_stack in user_item_stacks:
		if user_item_stack.block == block_scene:
			user_item_stack.count += count
			save_user_data()
			return
	user_item_stacks.push_back(ItemStack.new(block_scene, count))
	print("get")
	save_user_data()

func save_user_data():
	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	for user_item_stack in user_item_stacks:
		var block = user_item_stack.block.instantiate()
		var dict = {
			"id": block.id,
			"count": user_item_stack.count
		}
		block.queue_free()
		file.store_var(dict)
	file.close()

func load_user_data():
	var file = FileAccess.open("user://save.dat", FileAccess.READ)
	if file == null:
		return
	user_item_stacks = []
	while file.get_position() < file.get_length():
		var data = file.get_var()
		if not data == null:
			var user_item_stack = ItemStack.new(
					load("res://src/editor/item/" + data["id"] + ".tscn"),
					data["count"]
			)
			user_item_stacks.push_back(user_item_stack)
	file.close()

func save_user_info(score: int):
	var file = FileAccess.open("user://info.dat", FileAccess.WRITE)
	var info = {
		"tutorial_1": tutorial_1,
		"high_score": score
	}
	file.store_var(info)
	file.close()

func load_user_info():
	var file = FileAccess.open("user://info.dat", FileAccess.READ)
	if file == null:
		return
	var info = file.get_var()
	if info == null:
		save_user_info(0)
	else:
		high_score = info["high_score"]
		tutorial_1 = info["tutorial_1"]
	file.close()

func clear_blocks():
	blocks.resize(14)
	for x in blocks:
		x.resize(14)
		x.fill(null)

func reload_items():
	item_stacks = []
	for item_stack in user_item_stacks:
		item_stacks.push_back(ItemStack.new(item_stack.block, item_stack.count))
