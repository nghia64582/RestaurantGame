extends Node2D

var state
var sprite_idx

@export var image: Sprite2D
@export_group("Cooking images")
@export var cooking_images: Array[Texture2D] = []
@export_group("Wait for order 1 images")
@export var wait_for_order_1_images: Array[Texture2D] = []
@export_group("Wait for order 2 images")
@export var wait_for_order_2_images: Array[Texture2D] = []

func _ready():
	state = ChefConst.STATE.COOKING
	sprite_idx = -1

func _process(delta):
	sprite_idx += 1
	var textures = get_textures_of_state()
	if sprite_idx / 1 >= len(textures):
		sprite_idx = 0
		state += 1
		if state > ChefConst.STATE.WAIT_FOR_ORDER:
			state = ChefConst.STATE.COOKING
	image.texture = textures[sprite_idx / 1]

func get_textures_of_state():
	if state == ChefConst.STATE.COOKING:
		return cooking_images
	if state == ChefConst.STATE.WAIT_FOR_ORDER:
		return wait_for_order_1_images
