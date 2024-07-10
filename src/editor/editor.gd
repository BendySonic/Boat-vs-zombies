extends Node2D

signal touch_released()

@export var editor_items: GridContainer
@export var tile_map: TileMap
@export var ship: Node2D
var touch_map_pos: Vector2
var tile_map_size := Rect2(Vector2(0, 0), Vector2(7, 7))

var is_panel_touch_inside := false

@onready var editor_item_scene: PackedScene = preload("res://src/editor/editor_item.tscn")
@onready var block_scene: PackedScene = preload("res://src/item/block.tscn")


func _input(event):
	# TileMap mouse
	var touch_map_local_pos = get_global_mouse_position() - tile_map.global_position
	touch_map_pos = (touch_map_local_pos / 96).floor()
	# Mouse hold
	if event is InputEventMouseButton:
		if event.is_released():
			touch_released.emit()

func _ready():
	load_items()
	ship.load_blocks()

func _on_menu_pressed():
	ship.save_blocks()
	get_tree().change_scene_to_file("res://src/game/game.tscn")

func _on_save_pressed():
	ship.save_blocks()

func _on_clear_pressed():
	reload_items()

func _on_item_drag(item: Item, editor_item: EditorItem):
	# Create block
	var block = block_scene.instantiate()
	block.set_item(item)
	ship.add_child(block)
	block.hold()
	block.global_position = get_global_mouse_position()
	block.last_pos = null
	prepare_block(block)
	await block.block_released
	# Item drop
	item.count -= 1

func _on_block_released(block: Block):
	if is_panel_touch_inside:
		block.return_to_items()
		return
	for block_child in ship.get_children():
		if block_child.position == ship.map_pos_to_local(touch_map_pos):
			block.cancel_drag()
			return
	if not tile_map_size.has_point(touch_map_pos):
		block.cancel_drag()
		return
	block.set_map_pos(ship, touch_map_pos)

func _on_panel_mouse_entered():
	is_panel_touch_inside = true

func _on_panel_mouse_exited():
	is_panel_touch_inside = false

func reload_items():
	for block in ship.get_children():
		block.queue_free()
	for editor_item in editor_items.get_children():
		editor_item.queue_free()
	
	Data.reload_items()
	load_items()

func load_items():
	for item in Data.items:
		var editor_item: EditorItem = editor_item_scene.instantiate()
		editor_item.set_item(item)
		editor_item.item_drag.connect(_on_item_drag)
		editor_items.add_child(editor_item)
		if item.count <= 0:
			editor_item.visible = false

func prepare_block(block):
	block.is_play = false
	block.block_released.connect(_on_block_released)
