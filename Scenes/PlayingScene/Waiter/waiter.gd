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
# for moving path
var cur_direction
var speed = 150 # pixel per second
var list_points = []

func _ready():
	update_z_order()
	sprite_idx = -1
	state = WaiterConst.STATE.IDLE
	
func _process(delta):
	update_sprite()
	update_state()
	check_and_move(delta)
	
func update_state():
	state = get_cur_state()

func get_cur_state():
	if cur_direction == null or cur_direction == GameConst.DIRECT.NONE:
		return WaiterConst.STATE.IDLE
	scale.x = -1 if cur_direction == GameConst.DIRECT.LEFT else 1
	if cur_direction == GameConst.DIRECT.RIGHT or\
		cur_direction == GameConst.DIRECT.LEFT:
		return WaiterConst.STATE.WALK_SIDE
	if cur_direction == GameConst.DIRECT.UP:
		return WaiterConst.STATE.WALK_BACK
	if cur_direction == GameConst.DIRECT.DOWN:
		return WaiterConst.STATE.WALK_FRONT
	return WaiterConst.STATE.IDLE

func update_sprite():
	sprite_idx += 1
	var textures = get_textures_of_state()
	if sprite_idx / 1 >= len(textures):
		sprite_idx = 0
	image.texture = textures[sprite_idx / 1]
	
func check_and_move(delta):
	if len(list_points) == 0:
		return
	var next_target = list_points[0]
	if position.distance_to(next_target) < GameConst.MIN_DIRECT:
		update_position(next_target.x, next_target.y)
		list_points.remove_at(0)
		update_next_target_and_direction()
	else:
		var x = position.x + GameConst.DIRECT_COOR[cur_direction].x * speed * delta
		var y = position.y + GameConst.DIRECT_COOR[cur_direction].y * speed * delta
		update_position(x, y)

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

func update_next_target_and_direction():
	if len(list_points) == 0:
		cur_direction = GameConst.DIRECT.NONE
		return
	var next_target = list_points[0]
	if next_target.x == position.x:
		if next_target.y < position.y:
			cur_direction = GameConst.DIRECT.UP
		else:
			cur_direction = GameConst.DIRECT.DOWN
	else:
		if next_target.x < position.x:
			cur_direction = GameConst.DIRECT.LEFT
		else:
			cur_direction = GameConst.DIRECT.RIGHT
			
func add_point(pos):
	var last_point = list_points[-1] if len(list_points) > 0 else position
	if last_point.x != pos.x and last_point.y != pos.y:
		list_points.append(Vector2(last_point.x, pos.y))
	list_points.append(pos)
	update_next_target_and_direction()

func update_position(x, y):
	position = Vector2(x, y)
	z_index = y
