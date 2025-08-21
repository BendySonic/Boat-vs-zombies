class_name Player
extends Block

@export var default_camera_zoom: Vector2

var camera: Camera2D

func _ready():
	super()
	Data.player = self

func get_camera():
	return camera

func _on_ship_loaded(blocks: int) -> void:
	super(blocks)
	camera = MapCamera2D.new()
	add_child(camera)
	camera.zoom = default_camera_zoom
	Data.player = self
