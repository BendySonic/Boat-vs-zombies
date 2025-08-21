extends PanelContainer

signal reward_choosed

var random
var luck = 0

var block: Block
var block_scene: PackedScene
var count := 0:
	set(value):
		count = clamp(value, 1, 100)

@export var name_label: Label
@export var count_label: Label
@export var info_label: Label
@export var icon: TextureRect

func set_results(score: int):
	random = randi_range(1, 10)
	
	if score < 700:
		luck = 1
	elif score >= 700 and score < 2000:
		luck = 2
	else:
		luck = 3
	randomize_reward()
	set_reward()

func randomize_reward():
	match luck:
		1:
			block_scene = Data.items.rare[randi_range(0, Data.items.rare.size() - 1)]
		2:
			if random <= 7:
				block_scene = Data.items.super_rare[randi_range(0, Data.items.super_rare.size() - 1)]
			else:
				block_scene = Data.items.rare[randi_range(0, Data.items.rare.size() - 1)]
		3:
			if random <= 3:
				block_scene = Data.items.super_rare[randi_range(0, Data.items.super_rare.size() - 1)]
			elif random > 3 and random <= 8:
				block_scene = Data.items.epic[randi_range(0, Data.items.epic.size() - 1)]
			else:
				block_scene = Data.items.rare[randi_range(0, Data.items.rare.size() - 1)]
	block = block_scene.instantiate()
	if luck <= 2:
		count = block.rare_max_count - randi_range(1, 3)
	else:
		count = block.epic_max_count - randi_range(1, 3)
	block.queue_free()

func set_reward():
	name_label.text = block.visual_name
	count_label.text = "x" + str(count)
	info_label.text = "Strength: " + str(block.strength)
	icon.texture = block.get_texture()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			Data.add_item(block_scene, count)
			reward_choosed.emit()

func _on_mouse_entered() -> void:
	scale = Vector2(1.1, 1.1)

func _on_mouse_exited() -> void:
	scale = Vector2(1, 1)
