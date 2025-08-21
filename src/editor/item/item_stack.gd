class_name ItemStack
extends Resource

signal count_updated(count: int)

@export var block: PackedScene
@export var count: int:
	set(value):
		if value <= 0:
			count = 0
			count_updated.emit(count)
		else:
			count = value
		count_updated.emit(count)

func _init(block, count):
	self.block = block
	self.count = count

func paint():
	count -= 1
	count_updated.emit(count)

func erase():
	count += 1
	count_updated.emit(count)
