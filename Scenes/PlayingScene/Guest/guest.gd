extends Node2D

var state
var sprite_idx = 0
@export var image: Sprite2D
@export_group("Angry 1 images")
@export var angry_1_images: Array[Texture2D] = []
@export_group("Angry 2 images")
@export var angry_2_images: Array[Texture2D] = []
@export_group("Back view anim 1")
@export var back_view_1_images: Array[Texture2D] = []
@export_group("Back view anim 2")
@export var back_view_2_images: Array[Texture2D] = []
@export_group("Bored 1")
@export var bored_1_images: Array[Texture2D] = []
@export_group("Bored 2")
@export var bored_2_images: Array[Texture2D] = []
@export_group("Call waiter")
@export var call_waiter_images: Array[Texture2D] = []
@export_group("Drink")
@export var drink_images: Array[Texture2D] = []
@export_group("Eat")
@export var eat_images: Array[Texture2D] = []
@export_group("Read menu")
@export var read_menu_images: Array[Texture2D] = []
@export_group("Satisfied 1")
@export var satisfied_1_images: Array[Texture2D] = []
@export_group("Satisfied 2")
@export var satisfied_2_images: Array[Texture2D] = []
@export_group("Satisfied 3")
@export var satisfied_3_images: Array[Texture2D] = []
@export_group("Stand and angry")
@export var stand_and_angry_images: Array[Texture2D] = []
@export_group("Stand and bored")
@export var stand_and_bored_images: Array[Texture2D] = []
@export_group("Stand and wait")
@export var stand_and_wait_images: Array[Texture2D] = []
@export_group("Waiting for the food 1")
@export var waiting_for_food_1_images: Array[Texture2D] = []
@export_group("Waiting for the food 2")
@export var waiting_for_food_2_images: Array[Texture2D] = []
@export_group("Waiting for the food 3")
@export var waiting_for_food_3_images: Array[Texture2D] = []

func _ready():
	update_z_order()
	state = GuestConst.STATE.BACK_VIEW
	sprite_idx = -1

func _process(delta):
	sprite_idx += 1
	var textures = get_textures_of_state()
	if sprite_idx / 1 >= len(textures):
		sprite_idx = 0
		state = randi_range(0, GuestConst.STATE.WAITING_FOR_THE_FOOD)
		#state += 1
		#if state > GuestConst.STATE.WAITING_FOR_THE_FOOD:
			#state = GuestConst.STATE.ANGRY
	image.texture = textures[sprite_idx / 1]

func set_state(new_state):
	state = new_state

func get_textures_of_state():
	if state == GuestConst.STATE.ANGRY:
		return angry_1_images
	if state == GuestConst.STATE.BACK_VIEW:
		return back_view_1_images
	if state == GuestConst.STATE.BORED:
		return bored_1_images
	if state == GuestConst.STATE.CALL_WAITER:
		return call_waiter_images
	if state == GuestConst.STATE.DRINK:
		return drink_images
	if state == GuestConst.STATE.EAT:
		return eat_images
	if state == GuestConst.STATE.READ_MENU:
		return read_menu_images
	if state == GuestConst.STATE.SATISFIED:
		return satisfied_1_images
	if state == GuestConst.STATE.STAND_AND_ANGRY:
		return stand_and_angry_images
	if state == GuestConst.STATE.STAND_AND_BORED:
		return stand_and_bored_images
	if state == GuestConst.STATE.STAND_AND_WAIT:
		return stand_and_wait_images
	if state == GuestConst.STATE.WAITING_FOR_THE_FOOD:
		return waiting_for_food_1_images

func update_z_order():
	z_index = position.y
	print("Z index guest = ", z_index)
