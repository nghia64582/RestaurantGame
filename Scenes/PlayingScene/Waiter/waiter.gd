extends Node2D

@export var image: Sprite2D
@export var state_lb: Label

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

var sprite_idx
var state
var guest_id
var id
# for moving path
var cur_direction
var speed = 100 # pixel per second
var list_points = []

func _ready():
	sprite_idx = -1
	guest_id = -1
	id = IdGenerator.get_waiter_id()
	update_state(WaiterConst.STATE.IDLE)
	update_z_order()
	update_state_label()

func _process(delta):
	update_sprite()
	check_and_move(delta)

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
		if len(list_points) == 0:
			print("Finish moving with state : " + WaiterConst.STATE_NAME[state])
			update_next_state()
	else:
		var x = position.x + GameConst.DIRECT_COOR[cur_direction].x * speed * delta
		var y = position.y + GameConst.DIRECT_COOR[cur_direction].y * speed * delta
		update_position(x, y)

func get_textures_of_state():
	if state == WaiterConst.STATE.WAIT_FOR_GUEST:
		return get_order_images
	if state == WaiterConst.STATE.IDLE:
		return idle_images
	if cur_direction == GameConst.DIRECT.DOWN:
		return walk_front_images
	if cur_direction == GameConst.DIRECT.UP:
		return walk_back_images
	if cur_direction in [GameConst.DIRECT.RIGHT, GameConst.DIRECT.LEFT]:
		scale.x = -1 if cur_direction == GameConst.DIRECT.LEFT else 1
		return walk_side_images
	return walk_back_images

func update_z_order():
	z_index = position.y + image.get_rect().size.y

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
	print("Waiter add point : " + str(pos))
	var last_point = list_points[-1] if len(list_points) > 0 else position
	if last_point.x != pos.x and last_point.y != pos.y:
		list_points.append(Vector2(last_point.x, pos.y))
	list_points.append(pos)
	update_next_target_and_direction()

func update_position(x, y):
	position = Vector2(x, y)
	z_index = y

func update_next_state():
	if state == WaiterConst.STATE.IDLE:
		update_state(WaiterConst.STATE.GO_TO_GUEST)
	elif state == WaiterConst.STATE.GO_TO_GUEST:
		update_state(WaiterConst.STATE.WAIT_FOR_GUEST)
	elif state == WaiterConst.STATE.WAIT_FOR_GUEST:
		update_state(WaiterConst.STATE.GO_TO_KITCHEN)
	elif state == WaiterConst.STATE.GO_TO_KITCHEN:
		update_state(WaiterConst.STATE.SEND_ORDER_TO_CHEF)
	elif state == WaiterConst.STATE.SEND_ORDER_TO_CHEF:
		update_state(WaiterConst.STATE.BRING_FOOD_TO_GUEST)
	elif state == WaiterConst.STATE.BRING_FOOD_TO_GUEST:
		update_state(WaiterConst.STATE.GO_TO_IDLE_POS)

func check_change_state():
	if state == WaiterConst.STATE.GO_TO_IDLE_POS:
		print("Waiter go to idle pos")
		add_point(Vector2(100, 100))

func update_state(new_state):
	check_change_state()
	state = new_state
	update_state_label()
	print("Waiter new state : " + WaiterConst.STATE_NAME[state])

func update_state_label():
	state_lb.text = WaiterConst.STATE_NAME[state]
