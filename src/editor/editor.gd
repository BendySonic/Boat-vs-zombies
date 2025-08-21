extends Node2D

signal rotate_set(rotate: float)

# Tutorial
signal player_choosed
signal engine_choosed
signal wood_choosed
signal painted
signal erased

@export var editor_items: Control
@export var tile_map: TileMap
@export var ship: Node2D

@export var play_button: TextureButton

@export var tap_1: PanelContainer
@export var tap_2: PanelContainer
@export var tap_3: PanelContainer
@export var tap_4: PanelContainer
@export var tap_5: PanelContainer
@export var tap_6: PanelContainer

@export var example: Node2D

@export var help: RichTextLabel

@export var info: RichTextLabel

const tile_map_size := Rect2(Vector2(0, 0), Vector2(14, 14))
enum Action {NONE, PAINT, ERASE}
var action: Action = Action.NONE
var choosed_item_stack: ItemStack

var rotate: float = PI * 0

# Editor info
var blocks := 0:
	set(value):
		blocks = value
		update_info()

@onready var editor_item_scene: PackedScene = preload("res://src/editor/editor_item.tscn")


func _unhandled_input(event: InputEvent) -> void:
	var mouse_map_local_pos = get_global_mouse_position() - tile_map.global_position
	var mouse_map_pos = (mouse_map_local_pos / 96).floor()
	# Mouse hold
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					action = Action.PAINT
				else:
					action = Action.NONE
			MOUSE_BUTTON_RIGHT:
				if event.is_pressed():
					action = Action.ERASE
				else:
					action = Action.NONE
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		match action:
			Action.PAINT:
				paint(mouse_map_pos)
				painted.emit()
			Action.ERASE:
				erase(mouse_map_pos)
				erased.emit()

func _ready():
	load_items()
	ship.loaded.connect(_on_ship_loaded)
	ship.load_blocks()
	choosed_item_stack = null
	
	if not Data.tutorial_1:
		example.show()
		help.hide()
		hide_taps()
		tap_1.show()
		await player_choosed
		hide_taps()
		tap_2.show()
		await painted
		hide_taps()
		tap_3.show()
		await wood_choosed
		hide_taps()
		tap_2.show()
		await painted
		hide_taps()
		tap_4.show()
		await engine_choosed
		hide_taps()
		tap_5.show()
		await rotate_set
		hide_taps()
		tap_2.show()
		await painted
		hide_taps()
		tap_6.show()
	example.hide()
	help.show()
	play_button.disabled = false

func hide_taps():
	tap_1.hide()
	tap_2.hide()
	tap_3.hide()
	tap_4.hide()
	tap_5.hide()

func _on_save_pressed():
	ship.save_blocks()

func _on_clear_pressed():
	reload_items()

func _on_item_choosed(item_stack: ItemStack, editor_item: EditorItem):
	choosed_item_stack = item_stack
	var block = item_stack.block.instantiate()
	if block is Player:
		player_choosed.emit()
	elif block.id == "engine":
		engine_choosed.emit()
	elif block.id == "wood":
		wood_choosed.emit()
	block.queue_free()

func paint(mouse_map_pos: Vector2):
	if choosed_item_stack == null:
		return
	if choosed_item_stack.count <= 0:
		return
	for block_child in ship.get_children():
		if block_child.position == ship.map_pos_to_local(mouse_map_pos):
			return
	if not tile_map_size.has_point(mouse_map_pos):
		return
	var block = choosed_item_stack.block.instantiate()
	ship.add_child(block)
	block.set_item_stack(choosed_item_stack)
	
	block.set_rotate(rotate)
	block.set_map_pos(ship, mouse_map_pos)
	blocks += 1

func erase(mouse_map_pos: Vector2):
	for block_child in ship.get_children():
		if block_child.position == ship.map_pos_to_local(mouse_map_pos):
			ship.remove_child(block_child)
			block_child.erase()
			blocks -= 1

func update_info():
	info.text = "[b]Parts: " + str(blocks) + "[/b]"

func reload_items():
	for block in ship.get_children():
		block.queue_free()
	for editor_item in editor_items.get_children():
		editor_item.queue_free()
	
	Data.reload_items()
	load_items()
	blocks = 0

func load_items():
	for item_stack in Data.item_stacks:
		var editor_item: EditorItem = editor_item_scene.instantiate()
		editor_item.set_item_stack(item_stack)
		editor_item.item_choosed.connect(_on_item_choosed)
		rotate_set.connect(editor_item._on_rotate_set)
		editor_items.add_child(editor_item)
		if item_stack.count <= 0:
			editor_item.visible = false

func _on_rotate_pressed() -> void:
	rotate += PI / 2
	if rotate == PI * 2:
		rotate = 0
	rotate_set.emit(rotate)

func _on_play_pressed() -> void:
	if ship.is_have_player():
		ship.save_blocks()
		get_tree().change_scene_to_file("res://src/loading.tscn")
		

func _on_delete_pressed() -> void:
	reload_items()

func _on_ship_loaded(blocks: int):
	self.blocks = blocks


func _on_menu_button_pressed() -> void:
	reload_items()
	get_tree().change_scene_to_file("res://src/menu/menu.tscn")
