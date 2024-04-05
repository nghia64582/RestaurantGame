extends Node2D

@export var image: Sprite2D

@export_group("get order image")
@export var get_order_images: Array[Texture2D] = []
@export_group("idle image")
@export var idle_images: Array[Texture2D] = []
@export_group("walk back image")
@export var walk_back_images: Array[Texture2D] = []
@export_group("walk back with plate image")
@export var walk_back_with_plate_images: Array[Texture2D] = []
@export_group("walk front image")
@export var walk_front_images: Array[Texture2D] = []
@export_group("walk front with 1 plate image")
@export var walk_front_with_1_plate_images: Array[Texture2D] = []
@export_group("walk front with 2 plates image")
@export var walk_front_with_2_plates_images: Array[Texture2D] = []
@export_group("walk front with menu image")
@export var walk_front_with_menu_images: Array[Texture2D] = []
@export_group("walk side image")
@export var walk_side_images: Array[Texture2D] = []
@export_group("walk side with menu image")
@export var walk_side_with_menu_images: Array[Texture2D] = []
@export_group("walk side with plate image")
@export var walk_side_with_plate_images: Array[Texture2D] = []

var sprite_idx = -1
var state

func _ready():
	update_z_order()
	sprite_idx = -1
	state = WaiterConst.STATE.GET_ORDER
	
func _process(delta):
	sprite_idx += 1
	var textures = get_textures_of_state()
	if sprite_idx / 1 >= len(textures):
		sprite_idx = 0
		state += 1
		if state > WaiterConst.STATE.WALK_SIDE_WITH_PLATE:
			state = WaiterConst.STATE.GET_ORDER
	image.texture = textures[sprite_idx / 1]
	
func get_textures_of_state():
	if state == WaiterConst.STATE.GET_ORDER:
		return get_order_images
	if state == WaiterConst.STATE.IDLE:
		return idle_images
	if state == WaiterConst.STATE.WALK_BACK:
		return walk_back_images
	if state == WaiterConst.STATE.WALK_BACK_WITH_PLATE:
		return walk_back_with_plate_images
	if state == WaiterConst.STATE.WALK_FRONT_WITH_1_PLATE:
		return walk_front_with_1_plate_images
	if state == WaiterConst.STATE.WALK_FRONT_WITH_2_PLATES:
		return walk_front_with_2_plates_images
	if state == WaiterConst.STATE.WALK_FRONT:
		return walk_front_images
	if state == WaiterConst.STATE.WALK_FRONT_WITH_MENU:
		return walk_front_with_menu_images
	if state == WaiterConst.STATE.WALK_SIDE:
		return walk_side_images
	if state == WaiterConst.STATE.WALK_SIDE_WITH_MENU:
		return walk_side_with_menu_images
	if state == WaiterConst.STATE.WALK_SIDE_WITH_PLATE:
		return walk_side_with_plate_images
	print(state)

func update_z_order():
	z_index = position.y + image.get_rect().size.y
	print("Z index = ", z_index)
