class_name Boss
extends Enemy

var boss_progress: TextureProgressBar

@export var boss_name: String

func setup_boss(boss_progress: TextureProgressBar, boss_label: Label):
	self.boss_progress = boss_progress
	self.boss_progress.max_value = strength
	self.boss_progress.value = strength
	boss_label.text = boss_name

func _on_strength_update() -> void:
	boss_progress.value = strength
