extends Node2D

@export var menu: MarginContainer
@export var currency: HBoxContainer
@export var ship: Node2D
@export var camera: Camera2D

var is_play := false

func _ready():
	ship.load_blocks()

func _physics_process(delta):
	force_ship()
	follow_camera()

func _on_ship_pressed():
	ship.save_blocks()
	get_tree().change_scene_to_file("res://src/editor/editor.tscn")

func _on_play_gui_input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if not is_play:
				start_game()

func start_game():
	menu.hide()
	currency.hide()
	ship.create_block_groups()
	is_play = true

func force_ship():
	if is_play:
		for rigid_body in ship.get_children():
			rigid_body.linear_velocity = Vector2(0, -60)

func follow_camera():
	if is_play:
		if not ship.get_player() == null:
			camera.global_position = ship.get_player().global_position


