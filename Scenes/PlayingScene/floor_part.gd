extends Node2D

@export var brick_image: Sprite2D

func get_size():
	return brick_image.texture.get_size() * brick_image.scale
