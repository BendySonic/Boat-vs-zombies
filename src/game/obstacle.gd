@tool
extends StaticBody2D

@export var texture: Texture2D:
	set(value):
		texture = value
		$Sprite2D.texture = value

