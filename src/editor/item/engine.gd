extends Block

var last_linear_velocity: Vector2

func engine():
	if is_ready and is_instance_valid(rigid_body):
		var force = Vector2(0, 0)
		if Input.is_action_pressed("up"):
			force = Vector2.RIGHT.rotated(rotation).rotated(rigid_body.rotation) * SPEED
		if Input.is_action_pressed("down"):
			force = Vector2.LEFT.rotated(rotation).rotated(rigid_body.rotation) * SPEED
		rigid_body.apply_central_force(force)
		
		if Input.is_action_pressed("right"):
			rigid_body.angular_velocity = PI / 2
		if Input.is_action_pressed("left"):
			rigid_body.angular_velocity = -PI / 2
		
		if not Input.is_action_pressed("right") and not Input.is_action_pressed("left"):
			rigid_body.angular_velocity = 0
		
		last_linear_velocity = rigid_body.linear_velocity

func _physics_process(delta: float) -> void:
	super(delta)
	engine()

func _on_block_group_updated():
	super()
	if is_instance_valid(rigid_body):
		rigid_body.linear_velocity = last_linear_velocity
