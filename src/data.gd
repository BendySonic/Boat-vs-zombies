extends Node

# Storage of all user items
var user_items: Array[Item]
# Items for build
var items: Array[Item]

var blocks: Array[Array]

func _ready():
	user_items = [
		Item.new(preload("res://src/item/wood.tres"), 5),
		Item.new(preload("res://src/item/wood_slope.tres"), 4),
		Item.new(preload("res://src/item/engine.tres"), 1),
		Item.new(preload("res://src/item/player.tres"), 1),
	]
	clear_blocks()
	reload_items()

func clear_blocks():
	blocks.resize(7)
	for x in blocks:
		x.resize(7)
		x.fill(null)

func reload_items():
	items = []
	for item in user_items:
		items.push_back(Item.new(item.item_type, item.count))


