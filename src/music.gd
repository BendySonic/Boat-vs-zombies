extends Node2D

func play_theme():
	var random = randi_range(1, 3)
	var sound = get_node("Main" + str(random))
	if random == 2:
		get_node("Start").play()
		await get_node("Start").finished
	sound.play()

func play_game_over():
	clear()
	get_node("GameOver").play()

func play_menu():
	get_node("Menu").play()

func clear():
	for child in get_children():
		child.playing = false


func _on_main_finished() -> void:
	play_theme()
