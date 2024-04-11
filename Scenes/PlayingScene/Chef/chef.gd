extends Node2D

var state
var sprite_idx
var count_down

@export var state_lb: Label
@export var image: Sprite2D
@export_group("Cooking images")
@export var cooking_images: Array[Texture2D] = []
@export_group("Wait for order 1 images")
@export var wait_for_order_1_images: Array[Texture2D] = []
@export_group("Wait for order 2 images")
@export var wait_for_order_2_images: Array[Texture2D] = []

func _ready():
	update_state(ChefConst.STATE.WAIT_FOR_ORDER)
	sprite_idx = -1

func _process(delta):
	update_sprite()
	check_and_update_cooking(delta)

func update_sprite():
	sprite_idx += 1
	var textures = get_textures_of_state()
	if sprite_idx / 1 >= len(textures):
		sprite_idx = 0
	image.texture = textures[sprite_idx / 1]

func get_textures_of_state():
	if state == ChefConst.STATE.COOKING:
		return cooking_images
	if state in [ChefConst.STATE.WAIT_FOR_ORDER, \
				ChefConst.STATE.FINISH_COOKING]:
		return wait_for_order_1_images

func check_and_update_cooking(delta):
	if state != ChefConst.STATE.COOKING:
		return
	count_down -= delta
	if count_down <= 0:
		print("Cooking countdown : " + str(count_down))
		update_state(ChefConst.STATE.FINISH_COOKING)

func start_cooking():
	if state != ChefConst.STATE.WAIT_FOR_ORDER:
		return
	update_state(ChefConst.STATE.COOKING)
	count_down = 3

func update_state(new_state):
	state = new_state
	state_lb.text = ChefConst.STATE_NAME[state]
