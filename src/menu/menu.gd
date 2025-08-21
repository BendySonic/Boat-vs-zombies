extends Control


@export var score: Label

@export var settings: Control
@export var menu: Control

func _ready():
	$AnimationPlayer.play("float")
	Data.load_user_info()
	score.text = "High score: " + str(Data.high_score)
	Music.play_menu()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://src/editor/editor.tscn")


func _on_settings_pressed() -> void:
	menu.hide()
	settings.show()


func _on_texture_rect_pressed() -> void:
	settings.hide()
	menu.show()
