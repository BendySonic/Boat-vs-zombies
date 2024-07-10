class_name Block
extends CollisionShape2D

signal block_pressed(block)
signal block_released(block)
signal block_destroyed(block)
 # Touch
var is_pressed := false
var is_hold := false
# Is game on
var is_play := false
# Position
var map_pos: Vector2
var last_pos
var last_global_transform
# Item reference
var item: Item
# Connections
var connections: Array[int] = []
var is_block_connected := false
# Block Data
var hp := 1:
	set(value):
		hp = value
		if value <= 0:
			block_destroyed.emit(self)

@export var texture: Sprite2D
@export var hitbox: Area2D
@export var hitbox_timer: Timer

func set_item(item: Item):
	self.item = item
	texture.texture = item.item_type.icon
	self.connections = item.item_type.connections
	self.hp = item.item_type.strength
#	define_mass()

func set_map_pos(ship, map_pos):
	self.map_pos = map_pos
	position = ship.map_pos_to_local(map_pos)

#func define_mass():
	#match item.item_type.name:
	#	"engine":
	#		mass = 1
	#	_:
	#		mass = item.item_type.strength * 0.01

func define_effect():
	if is_play:
		match item.item_type.name:
			"engine":
				if Input.is_action_pressed("up"):
					get_parent().linear_velocity = Vector2.RIGHT.rotated(rotation).rotated(get_parent().rotation) * 200
				if Input.is_action_pressed("down"):
					get_parent().linear_velocity = Vector2.LEFT.rotated(rotation).rotated(get_parent().rotation) * 200
				if Input.is_action_pressed("right"):
					get_parent().angular_velocity = PI
				if Input.is_action_pressed("left"):
					get_parent().angular_velocity = -PI
			
				if not Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
					get_parent().angular_velocity = 0
				

func _physics_process(delta):
	define_effect()

func _input(event):
	if event is InputEventMouseMotion:
		if is_pressed:
			hold()
			is_pressed = false
	if is_hold and not is_play:
		if event is InputEventMouseMotion:
			global_position += event.relative
		if event is InputEventMouseButton:
			if event.is_released():
				is_hold = false
				is_pressed = false
				block_released.emit(self)

func _on_touch_screen_button_pressed():
	if not is_play:
		is_pressed = true

func _on_touch_screen_button_released():
	if is_pressed and not is_play:
		rotation += PI / 2
		rotate_connections()
		is_pressed = false

func hold():
	is_hold = true
	last_pos = global_position
	block_pressed.emit(self)

func return_to_items():
	item.count += 1
	item.editor_item.visible = true
	queue_free()

func cancel_drag():
	if last_pos == null:
		return_to_items()
		return
	global_position = last_pos

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
	var hit_bodies = hitbox.get_overlapping_bodies()
	for body in hit_bodies:
		if body.is_in_group("obstacle"):
			hp -= 1
