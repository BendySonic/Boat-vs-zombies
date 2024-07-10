class_name EditorItem
extends AspectRatioContainer


signal item_drag(item, editor_item)

@export var texture: TextureRect
@export var count_label: Label
var item: Item


func set_item(item: Item):
	self.item = item
	item.editor_item = self
	texture.texture = item.item_type.icon
	count_label.text = str(item.count) + "X"

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			item_drag.emit(item, self)

func update_count():
	count_label.text = str(item.count) + "X"
