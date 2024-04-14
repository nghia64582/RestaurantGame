extends Node2D

@export var food_images: Array[Texture2D]
@export var drink_images: Array[Texture2D]
@export var image: Sprite2D
var type

func _ready():
	pass

func set_type(food_type):
	type = food_type
	image.texture = food_images[type]

func set_random_type():
	type = randi_range(0, 6)
	image.texture = food_images[type]
	
