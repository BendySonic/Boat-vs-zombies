extends Control

var enemy: PackedScene = preload("res://src/game/enemies/enemy.tscn")

func _ready():
	var new_enemy: Enemy = enemy.instantiate()
	add_child(new_enemy)
	new_enemy.global_position = Vector2(500, 500)
	new_enemy.modulate = Color(0, 0, 0, 0.3)
	new_enemy.emit_crash_particles()
	
	await new_enemy.crash_particles.finished
	new_enemy.queue_free()
	get_tree().change_scene_to_file("res://src/game/game.tscn")
