class_name Item
extends Resource

@export var item_type: ItemType
@export var count: int:
	set(value):
		if value <= 0:
			editor_item.visible = false
			count = 0
		else:
			count = value
		if not editor_item == null:
			editor_item.update_count()

var editor_item: EditorItem

func _init(item_type, count):
	self.item_type = item_type
	self.count = count
