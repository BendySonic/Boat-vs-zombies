extends Node2D

signal boss_killed

@export_category("Children")
@export var ship: Node2D
@export var wave_timer: Timer
@export var wave_progress: TextureProgressBar
@export var wave_label: Label
@export var enemies_label: Label
@export var boss_progress: TextureProgressBar
@export var boss_container: Control
@export var boss_label: Label
@export var sea_particles: GPUParticles2D

@export var ui: CanvasLayer
@export var choose: CanvasLayer
@export var game_over: CanvasLayer
@export var game_over_label: Label
@export var result: RichTextLabel

@export var rewards: HBoxContainer

@export var ui_animation: AnimationPlayer
@export var wave_text: Label

@export var game_over_animation: AnimationPlayer

@export var wasd: PanelContainer
@export var tutorial_animation: AnimationPlayer

@onready var heal_scene: PackedScene = preload("res://src/game/Heal.tscn")

@export var pause: PanelContainer

@export_category("Custom")
@export var waves: Waves

const MAP_SIZE = 35
const WAVE_SCORE = 100
const ENEMIS_KILLED_SCORE = 2
const COMBO_SCORE = 1

# Game data
var wave: int = 1:
	set(value):
		wave = value
		wave_label.text = "Wave " + str(value)
		load_wave(value)
var enemies: int = 0:
	set(value):
		enemies = value
		if value <= 0:
			enemies = 0
			wave += 1
		enemies_label.text = str(enemies) + " enemies left"
var enemies_killed := 0
var combo_bonus := 0
var score := 0

var paused := false

var is_boss := false

func _ready():
	start_game()
	
	if not Data.tutorial_1:
		Data.tutorial_1 = true
		Data.save_user_info(Data.high_score)
	tutorial_animation.play("show_wasd")
	await get_tree().create_timer(15).timeout
	tutorial_animation.play_backwards("show_wasd")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		print("OK")
		paused = not paused
		get_tree().paused = paused
		if paused:
			pause.show()
		else:
			pause.hide()

func start_game():
	ship.load_blocks()
	ship.play()
	ship.died.connect(_on_died)
	
	Music.clear()
	Music.play_theme()
	
	set_sea_particles()
	ui.show()
	
	await get_tree().create_timer(3).timeout
	load_wave(wave)
	
	update_wave_progress()

func end_game():
	score = (
			(wave - 1) * WAVE_SCORE
			+ enemies_killed * ENEMIS_KILLED_SCORE 
			+ combo_bonus * COMBO_SCORE
	)
	ui.hide()
	game_over.show()
	game_over_animation.play("show_game_over")
	result.text = (
			"Waves survived: " + str(wave - 1) + "[color=dark gray] x100 [/color]"
			+ "\nZombies killed: " + str(enemies_killed) + "[color=dark gray] x2 [/color]"
			+ "\nCombo bonus: " + str(combo_bonus)
			+ "\n[b]Score: " + str(score) + "[/b]"
	)
	wave_timer.stop()
	if score > Data.high_score:
		Data.save_user_info(score)
	Music.play_game_over()

func _on_continue_pressed() -> void:
	game_over.hide()
	set_rewards()
	choose.show()

func set_rewards():
	for reward in rewards.get_children():
		reward.set_results(score)
		reward.reward_choosed.connect(_on_reward_choosed)

func _on_reward_choosed():
	ship.save_blocks()
	Music.clear()
	Music.get_node("Menu").playing = true
	get_tree().change_scene_to_file("res://src/editor/editor.tscn")

#func _on_ship_pressed():
#	ship.save_blocks()
#	get_tree().change_scene_to_file("res://src/editor/editor.tscn")

func load_wave(wave: int):
	if wave == 27:
		game_over_label.text = "You won!"
		end_game()
		return
	boss_container.hide()
	for group in waves.waves[wave - 1].wave:
		for i in range(0, group.count):
			var enemy = group.enemy_type.instantiate()
			var enemy_position = Vector2(0, 3000)
			enemy_position = enemy_position.rotated(PI * 2 * randf())
			enemy.position = enemy_position
			enemy.died.connect(_on_enemy_died)
			enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
			if enemy is Boss:
				boss_container.show()
				enemy.setup_boss(boss_progress, boss_label)
				enemy.died.connect(_on_boss_died)
				is_boss = true
			add_child.call_deferred(enemy)
			enemies += 1
	wave_timer.stop()
	wave_timer.start()
	wave_progress.value = 60
	wave_text.text = str(waves.waves[wave - 1].wave_text)
	ui_animation.play("wave_text_show")
	await get_tree().create_timer(4).timeout
	ui_animation.play_backwards("wave_text_show")

func update_wave_progress():
	while true:
		if not paused and not is_boss:
			wave_progress.value -= 1
		await get_tree().create_timer(1).timeout
		print("ok")

func _on_wave_timer_timeout() -> void:
	if not is_boss:
		wave += 1

func _on_enemy_died():
	var camera = get_viewport().get_camera_2d()
	if not camera == null and is_instance_valid(camera) and camera is MapCamera2D:
		camera.shake()
	enemies -= 1
	enemies_killed += 1

func _on_boss_died():
	is_boss = false
	boss_killed.emit()
	wave += 1
	boss_container.hide()

func _on_died():
	Data.player = null
	end_game()

func set_sea_particles():
	sea_particles.restart()

func _physics_process(delta: float) -> void:
	sea_particles.global_position = get_viewport().get_camera_2d().global_position


func _on_heal_timer_timeout() -> void:
	if not heal_scene == null:
		var heal = heal_scene.instantiate()
		add_child(heal)
		var heal_position = Vector2(0, 3000)
		heal_position = heal_position.rotated(PI * 2 * randf())
