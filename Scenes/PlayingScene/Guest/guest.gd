extends Node2D

var sprite_idx
var state
var id
var table
var waiter
# for moving path
var cur_direction
var speed = 300 # pixel per second
var list_points = []
var state_count_down
var max_count_down
var order
var react_anim
var game
var pre_pos
var pre_z_index
var called_waiter
@export var state_lb: Label
@export var image: Sprite2D
@export var progress_bar: ProgressBar
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
	called_waiter = false
	id = IdGenerator.get_guest_id()
	update_z_order()

func _process(delta):
	update_sprite()
	check_and_move(delta)
	check_current_state()
	update_state_count_down(delta)
	update_state_label()
	update_progress_bar()
	
func update_state_count_down(delta):
	if state not in [GuestConst.STATE.PICK_FOOD, GuestConst.STATE.HAVE_MEAL]:
		return
	state_count_down -= delta
	if state_count_down <= 0:
		update_next_state()
	if state == GuestConst.STATE.HAVE_MEAL:
		if GameUtils.float_modulo(state_count_down, 3) < delta:
			table.remove_food_with_idx(int(state_count_down) / 3)

func update_progress_bar():
	if max_count_down == 0 or state_count_down <= 0.1:
		progress_bar.visible = false
	else:
		progress_bar.visible = true
		progress_bar.value = (state_count_down / max_count_down) * 100

func update_sprite():
	sprite_idx += 1
	var textures = get_textures_of_state()
	if sprite_idx / 3 >= len(textures):
		sprite_idx = 0
	image.texture = textures[sprite_idx / 3]

func check_current_state():
	if state == GuestConst.STATE.REACT and not called_waiter:
		var success = game.call_waiter_for_payment(self)
		if success:
			called_waiter = true
	if state == GuestConst.STATE.WAIT_FOR_WAITER and not called_waiter:
		var success = game.call_waiter_for_menu(self)
		if success:
			called_waiter = true

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
		return stand_and_wait_images
	if state == GuestConst.STATE.WAIT_FOR_WAITER:
		return call_waiter_images
	if state == GuestConst.STATE.PICK_FOOD:
		return read_menu_images
	if state == GuestConst.STATE.WAIT_FOR_MEAL:
		return waiting_for_food_1_images
	if state == GuestConst.STATE.HAVE_MEAL:
		return eat_images
	if state == GuestConst.STATE.REACT:
		return react_anim
	if state == GuestConst.STATE.LEAVE:
		return stand_and_wait_images
	return stand_and_wait_images

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
	print("Addpoint %s, new list point %s" % [pos, list_points])
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
		update_state(GuestConst.STATE.HAVE_MEAL, 3 * len(order.foods_id))
	elif state == GuestConst.STATE.HAVE_MEAL:
		update_state(GuestConst.STATE.REACT, 0)
	elif state == GuestConst.STATE.REACT:
		update_state(GuestConst.STATE.LEAVE, 0)
	elif state == GuestConst.STATE.LEAVE:
		update_state(GuestConst.STATE.LEFT, 0)

func update_state_label():
	state_lb.text = "Id %d\n%s\nC %d\nT %.2f" % [id, GuestConst.STATE_NAME[state]\
		, 1 if called_waiter else 0, state_count_down]

func update_state(new_state, count_down):
	check_change_state(new_state)
	state = new_state
	state_count_down = count_down
	max_count_down = count_down
	print("Guest change to state : " + GuestConst.STATE_NAME[state])

func check_change_state(new_state):
	if new_state == GuestConst.STATE.REACT:
		pick_random_react_anim()
		called_waiter = false
	if new_state == GuestConst.STATE.LEFT:
		game.floor_node.remove_child(self)
		game.guests.erase(self)
		queue_free()
	if new_state == GuestConst.STATE.WAIT_FOR_MEAL:
		pick_food()
	if new_state == GuestConst.STATE.WAIT_FOR_WAITER:
		called_waiter = false
		game.do_guest_sit_on_table(self)
	if new_state == GuestConst.STATE.LEAVE:
		game.do_guest_leave_table(self)
	if new_state == GuestConst.STATE.HAVE_MEAL:
		table.update_foods(order.foods_id)

func pick_food():
	var kitchen = game.find_free_kitchen()
	if kitchen == null:
		return
	order = Order.new()
	order.foods_id = FoodHelper.get_random_foods()
	order.guest = self
	order.waiter = waiter
	order.table = table
	order.kitchen = kitchen
	order.state = OrderConst.STATE.NOT_ORDERED
	kitchen.main_chef.update_state(ChefConst.STATE.ORDERED)
	var kitchen_pos = order.kitchen.position
	var waiter_pos = order.kitchen.waiter_pos.position
	var x = kitchen_pos.x + waiter_pos.x * game.component_node.scale.x
	var y = kitchen_pos.y + waiter_pos.y * game.component_node.scale.x
	waiter.add_point(Vector2(x, y))
	waiter.update_next_state()
	print("Guest %d picked food %s, waiter %d, kitchen %d" %
		[id, str(order.foods_id), waiter.id, order.kitchen])

func pick_random_react_anim():
	var list_anim = [angry_1_images, angry_2_images, satisfied_1_images,\
					 satisfied_2_images, satisfied_3_images]
	var idx = randi_range(0, len(list_anim) - 1)
	react_anim = list_anim[idx]
