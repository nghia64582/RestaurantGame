extends Node2D

var sprite_idx
var state
var id
var table_id
var waiter_id
# for moving path
var cur_direction
var speed = 100 # pixel per second
var list_points = []
var state_count_down
var order
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
	update_state(GuestConst.STATE.GO_TO_TABLE, 0)
	sprite_idx = -1
	id = IdGenerator.get_guest_id()
	update_z_order()
	update_state_label()

func _process(delta):
	update_sprite()
	check_and_move(delta)
	update_state_count_down(delta)
	
func update_state_count_down(delta):
	if state not in [GuestConst.STATE.PICK_FOOD, GuestConst.STATE.HAVE_MEAL]:
		return
	state_count_down -= delta
	if state_count_down <= 0:
		update_next_state()

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
			update_next_state()
	else:
		var x = position.x + GameConst.DIRECT_COOR[cur_direction].x * speed * delta
		var y = position.y + GameConst.DIRECT_COOR[cur_direction].y * speed * delta
		update_position(x, y)

func get_textures_of_state():
	if state == GuestConst.STATE.GO_TO_TABLE:
		return angry_1_images
	if state == GuestConst.STATE.WAIT_FOR_WAITER:
		return call_waiter_images
	if state == GuestConst.STATE.PICK_FOOD:
		return read_menu_images
	if state == GuestConst.STATE.WAIT_FOR_MEAL:
		return waiting_for_food_1_images
	if state == GuestConst.STATE.HAVE_MEAL:
		return eat_images
	if state == GuestConst.STATE.REACT:
		return angry_1_images
	if state == GuestConst.STATE.LEAVE:
		return back_view_1_images
	return back_view_1_images

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
	if state == GuestConst.STATE.GO_TO_TABLE:
		update_state(GuestConst.STATE.WAIT_FOR_WAITER, 0)
	elif state == GuestConst.STATE.PICK_FOOD:
		update_state(GuestConst.STATE.WAIT_FOR_MEAL, 0)
	elif state == GuestConst.STATE.WAIT_FOR_MEAL:
		update_state(GuestConst.STATE.HAVE_MEAL, 5)
	elif state == GuestConst.STATE.HAVE_MEAL:
		update_state(GuestConst.STATE.REACT, 0)
	elif state == GuestConst.STATE.REACT:
		update_state(GuestConst.STATE.LEAVE, 0)
	elif state == GuestConst.STATE.LEAVE:
		update_state(GuestConst.STATE.LEFT, 0)
	update_state_label()

func update_state_label():
	state_lb.text = GuestConst.NAME[state]

func update_state(new_state, count_down):
	check_change_state(new_state)
	state = new_state
	state_count_down = count_down
	update_state_label()
	
func check_change_state(new_state):
	if state == GuestConst.STATE.PICK_FOOD:
		pick_food()
	if new_state == GuestConst.STATE.LEAVE:
		add_point(Vector2(10, 250)) 

func pick_food():
	order = Order.new()
	order.foods_id = [1, 2]
	order.guest_id = id
	order.waiter_id = waiter_id
	order.table_id = table_id
	order.kitchen_id = 1
	order.state = OrderConst.STATE.NOT_ORDERED
	print("Guest %d picked food %s, waiter %d, kitchen %d" %
		[id, str(order.foods_id), waiter_id, order.kitchen_id])
