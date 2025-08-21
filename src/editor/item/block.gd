class_name Block
extends CollisionShape2D

signal block_destroyed(block: Block)
signal block_hit(enemy)
signal heal

const SPEED := 450


#region Physics engine (Ship destruction workflow)
var last_global_transform
var rigid_body: RigidBody2D:
	set(value):
		rigid_body = value
		define_mass() # Parent part
#endregion

var is_ready := false
# Position on Ship TileMap
var map_pos: Vector2
var map_rotate: float
# Item reference
var item_stack: ItemStack

@export_category("Chidlren")
@export var sprite: Sprite2D
@export var hitbox: Area2D

var hitbox_timer: Timer = Timer.new()
var inside_hitbox_enemies: Array
var can_hit := false

@export_category("Custom")
var strength_0
@export var strength: int:
	set(value):
		strength = value
		if value <= 0:
			is_ready = false
			block_destroyed.emit(self)
# Connections
var is_block_connected := false
@export var connections: Array[int]
@export_category("Rarity")
@export var visual_name: String
@export var rare_max_count: int
@export var epic_max_count: int
@export_category("Save")
@export var id: String


func _ready():
	strength_0 = strength
	hitbox_timer.wait_time = 0.5
	hitbox_timer.one_shot = false
	hitbox_timer.autostart = true
	hitbox_timer.timeout.connect(_on_hit_box_timer_timeout)
	add_child(hitbox_timer)
	can_hit = true

func _physics_process(delta: float) -> void:
	if can_hit:
		var old_inside_hitbox_enemies = inside_hitbox_enemies
		inside_hitbox_enemies = []
		for enemy in old_inside_hitbox_enemies:
			if not enemy == null:
				if is_instance_valid(enemy):
					inside_hitbox_enemies.push_back(enemy)
		for enemy in inside_hitbox_enemies:
			enemy.hit(self)
			block_hit.emit(enemy)
			play_break()
			can_hit = false
			if hitbox_timer.is_stopped():
				hitbox_timer.start()

func set_item_stack(item_stack: ItemStack):
	self.item_stack = item_stack
	item_stack.paint()
#	define_mass()

func set_map_pos(ship, map_pos):
	self.map_pos = map_pos
	position = ship.map_pos_to_local(map_pos)

func reload(ship):
	position = ship.map_pos_to_local(map_pos)
	set_rotate(map_rotate)
	last_global_transform = global_transform
	strength = strength_0
	define_mass()

func define_mass():
	if is_instance_valid(rigid_body):
		rigid_body.mass += strength_0 * 0.002

func erase():
	item_stack.erase()
	queue_free()

func set_rotate(rotate: float):
	rotation = rotate
	for i in range(0, rotate / (PI / 2)):
		rotate_connections()
	self.map_rotate = rotate

func rotate_connections():
	for side in connections:
		var index = connections.find(side)
		connections[index] = rotate_side(side)

func rotate_side(side: Side):
	match side:
		1:
			return 2
		2:
			return 3
		3:
			return 4
		4:
			return 1

func _on_hit_box_timer_timeout():
	can_hit = true
	var bodies = hitbox.get_overlapping_bodies()
	inside_hitbox_enemies = []
	for body in bodies:
		if body.is_in_group("obstacle"):
			inside_hitbox_enemies.push_back(body)

func _on_ship_loaded(blocks: int):
	hitbox.collision_layer = 1
	hitbox.collision_mask = 3
	if is_instance_valid(rigid_body):
		rigid_body.collision_layer = 1
		rigid_body.collision_mask = 3
	define_mass()

func _on_block_group_updated():
	define_mass()

func play_break():
	var sound = get_node("Break" + str(randi_range(1, 2)))
	sound.volume_db = -5
	if not sound.playing:
		sound.play(0)

func get_texture():
	return sprite.texture
