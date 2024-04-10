extends Node2D

var sprite_idx
var anim_state
var work_state
# for moving path
var cur_direction
var speed = 100 # pixel per second
var list_points = []
@export var state_lb: Label
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
	anim_state = GuestConst.ANIM_STATE.BACK_VIEW
	work_state = GuestConst.WORK_STATE.GO_TO_TABLE
	sprite_idx = -1
	update_z_order()
	update_state_label()

func _process(delta):
	update_sprite()
	update_anim_state()
	check_and_move(delta)
	
func update_sprite():
	sprite_idx += 1
	var textures = get_textures_of_state()
	if sprite_idx / 1 >= len(textures):
		sprite_idx = 0
		anim_state = randi_range(0, GuestConst.ANIM_STATE.WAITING_FOR_THE_FOOD)
	image.texture = textures[sprite_idx / 1]

func check_and_move(delta):
	if len(list_points) == 0:
		return
	var next_target = list_points[0]
	if position.distance_to(next_target) < GameConst.MIN_DIRECT:
		update_position(next_target.x, next_target.y)
		list_points.remove_at(0)
		update_next_target_and_direction()
		if len(list_points) == 0:
			update_next_state()
	else:
		var x = position.x + GameConst.DIRECT_COOR[cur_direction].x * speed * delta
		var y = position.y + GameConst.DIRECT_COOR[cur_direction].y * speed * delta
		update_position(x, y)

func update_anim_state():
	anim_state = get_cur_state()

func get_cur_state():
	if cur_direction == null or cur_direction == GameConst.DIRECT.NONE:
		return GuestConst.ANIM_STATE.READ_MENU
	scale.x = -1 if cur_direction == GameConst.DIRECT.LEFT else 1
	if cur_direction in [GameConst.DIRECT.RIGHT, GameConst.DIRECT.LEFT]:
		return GuestConst.ANIM_STATE.BACK_VIEW
	if cur_direction == GameConst.DIRECT.UP:
		return GuestConst.ANIM_STATE.BACK_VIEW
	if cur_direction == GameConst.DIRECT.DOWN:
		return GuestConst.ANIM_STATE.BACK_VIEW
	return GuestConst.ANIM_STATE.BACK_VIEW

func set_anim_state(new_state):
	anim_state = new_state

func get_textures_of_state():
	if anim_state == GuestConst.ANIM_STATE.ANGRY:
		return angry_1_images
	if anim_state == GuestConst.ANIM_STATE.BACK_VIEW:
		return back_view_1_images
	if anim_state == GuestConst.ANIM_STATE.BORED:
		return bored_1_images
	if anim_state == GuestConst.ANIM_STATE.CALL_WAITER:
		return call_waiter_images
	if anim_state == GuestConst.ANIM_STATE.DRINK:
		return drink_images
	if anim_state == GuestConst.ANIM_STATE.EAT:
		return eat_images
	if anim_state == GuestConst.ANIM_STATE.READ_MENU:
		return read_menu_images
	if anim_state == GuestConst.ANIM_STATE.SATISFIED:
		return satisfied_1_images
	if anim_state == GuestConst.ANIM_STATE.STAND_AND_ANGRY:
		return stand_and_angry_images
	if anim_state == GuestConst.ANIM_STATE.STAND_AND_BORED:
		return stand_and_bored_images
	if anim_state == GuestConst.ANIM_STATE.STAND_AND_WAIT:
		return stand_and_wait_images
	if anim_state == GuestConst.ANIM_STATE.WAITING_FOR_THE_FOOD:
		return waiting_for_food_1_images

func update_z_order():
	z_index = position.y

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

func update_next_state():
	if work_state == GuestConst.WORK_STATE.GO_TO_TABLE:
		work_state = GuestConst.WORK_STATE.WAIT_FOR_WAITER
	elif work_state == GuestConst.WORK_STATE.WAIT_FOR_WAITER:
		work_state = GuestConst.WORK_STATE.PICK_FOOD
	elif work_state == GuestConst.WORK_STATE.PICK_FOOD:
		work_state = GuestConst.WORK_STATE.WAIT_FOR_MEAL
	elif work_state == GuestConst.WORK_STATE.WAIT_FOR_MEAL:
		work_state = GuestConst.WORK_STATE.HAVE_MEAL
	elif work_state == GuestConst.WORK_STATE.HAVE_MEAL:
		work_state = GuestConst.WORK_STATE.REACT
	elif work_state == GuestConst.WORK_STATE.REACT:
		work_state = GuestConst.WORK_STATE.LEAVE
	update_state_label()

func update_state_label():
	state_lb.text = GuestConst.NAME[work_state]
