extends Node2D

@export var image: Sprite2D

func get_height():
	return image.get_rect().size.y * image.scale.y
