@tool
extends StaticBody2D

@export var texture: Texture2D:
	set(value):
		texture = value
		$Sprite2D.texture = value
@export var texture_scale = Vector2(1, 1):
	set(value):
		$Sprite2D.scale = value
		texture_scale = value
@export var strength: int = 1:
	set(value):
		strength = value
@export var can_destroy := true

func hit():
	if not Engine.is_editor_hint():
		if can_destroy:
			strength -= 1
			if strength <= 0:
				queue_free()
			scale *= 0.65
