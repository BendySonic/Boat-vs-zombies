class_name EditorItem
extends AspectRatioContainer


signal item_choosed(item, editor_item)

@export var texture: TextureRect
@export var count_label: Label
var item_stack: ItemStack


func set_item_stack(item_stack: ItemStack):
	self.item_stack = item_stack
	item_stack.count_updated.connect(_on_item_stack_count_updated)
	var block = item_stack.block.instantiate()
	match block.id:
		"engine":
			tooltip_text = "Engine: use it for\nride the boat"
		"player":
			tooltip_text = "Player: it's YOU!\nKeep yourself safe!"
		"wood":
			tooltip_text = "Wood: easy destroyable"
		"metal":
			tooltip_text = "Metal: hard destroyable"
		"spikes":
			tooltip_text = "Spikes: smash zombies!"
	texture.texture = block.get_texture()
	block.queue_free()
	count_label.text = "x" + str(item_stack.count)

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			item_choosed.emit(item_stack, self)

func _on_item_stack_count_updated(count: int):
	if count <= 0:
		visible = false
	else:
		visible = true
	count_label.text = str(count) + "X"

func _on_rotate_set(rotate: float):
	texture.rotation = rotate
