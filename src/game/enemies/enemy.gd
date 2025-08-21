class_name Enemy
extends RigidBody2D

signal died
signal strength_update

var can_hit := true
var can_destroy = true


@export_category("Children")
@export var crash_particles: GPUParticles2D
@export var water_particles: GPUParticles2D
@export var visuals: Node2D
@export var hitbox_timer: Timer
@export_category("Custom")
@export var speed: int = 400
@export var strength := 2
@export var bonus_hit := 0


var particles = preload("res://src/game/enemies/enemy.tres")

func _ready() -> void:
	crash_particles.process_material = Data.particles
	collision_layer = 2
	collision_mask = 1

func _physics_process(delta: float) -> void:
	if not Data.player == null:
		linear_velocity = Data.player.global_position - global_position
		linear_velocity = linear_velocity * 600
		linear_velocity = linear_velocity.limit_length(speed)
	
func hit(block: Block):
	if not Engine.is_editor_hint():
		if can_destroy and can_hit:
			block.strength -= (1 + bonus_hit)
			strength -= 1
			strength_update.emit()
			if strength <= 0:
				die()
			else:
				emit_crash_particles()
			can_hit = false
			hitbox_timer.start()
			return false

func emit_crash_particles():
	crash_particles.emitting = true
	

func die():
	visuals.hide()
	emit_crash_particles()
	died.emit()
	await crash_particles.finished
	queue_free()

func _on_hit_box_timer_timeout() -> void:
	can_hit = true
