extends Node2D
class_name Guest

var sprite_idx
var state
var id
var table
var waiter
# for moving path
var cur_direction
var speed = 150 # pixel per second
var list_points = []
var state_count_down
var max_count_down
var order
var react_anim
var game: MainGame
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

func _draw():
	if DevConfig.SHOW_PATH:
		for idx in range(len(list_points)):
			var point = list_points[idx]
			var pre_point = position if idx == 0 else list_points[idx - 1]
			var p1 = Vector2(pre_point.x - position.x, pre_point.y - position.y)
			var p2 = Vector2(point.x - position.x, point.y - position.y)
			draw_line(p1, p2, Color.RED, 1.0, true)

func _ready():
	update_state(GuestConst.STATE.GO_TO_TABLE, 0)
	sprite_idx = -1
	called_waiter = false
	id = IdGenerator.get_guest_id()
	update_z_order()

func _process(delta):
	queue_redraw()
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
		if GameUtils.is_middle_straight(next_target, position, Vector2(x, y)):
			x = next_target.x
			y = next_target.y
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
	if abs(next_target.x - position.x) < 1e-2:
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
	var waiter_pos = order.kitchen.waiter_pos
	waiter.find_path(waiter_pos)
	waiter.update_state(WaiterConst.STATE.GO_TO_KITCHEN)
	print("Guest %d picked food %s, waiter %d, kitchen %d" %
		[id, str(order.foods_id), waiter.id, order.kitchen])

func pick_random_react_anim():
	var list_anim = [angry_1_images, angry_2_images, satisfied_1_images,\
					 satisfied_2_images, satisfied_3_images]
	var idx = randi_range(0, len(list_anim) - 1)
	react_anim = list_anim[idx]

# FINDING PATH METHODS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
func find_path(target: Vector2):
	var t0 = Time.get_ticks_msec()
	var unit = PathFinder.UNIT
	var result = PathFinder.find_path(position, target)
	var last_point
	var distance
	if result != null:
		print("Guest find path by cache")
		distance = result["distance"]
		last_point = result["last_point"]
	else:
		print("Guest find path by algo")
		result = bfs(target, unit)
		distance = result["distance"]
		last_point = result["last_point"]
	var t1 = Time.get_ticks_msec()
	# traceback to find the shortest path
	var path = trace_back(last_point, distance, unit)
	add_path(path, target)
	update_next_target_and_direction()
	print("Guest cur pos %s, path %s" % [position, list_points])
	print("Guest find path time : %.2f, points size : %d" % \
		[t1 - t0, distance.size()])

func bfs(target, unit):
	# Use BFS to find path to all available points in game
	var queue = [position]
	var distance = {GameUtils.convert_point_to_hash(position): 0}
	var stop = false
	var count = 0
	var min_dist = 100000
	var last_point = Vector2(0, 0)
	var directs = GameUtils.get_random_directs(unit)
	print("Waiter start find path, start %s, target %s" % [position, target])
	while not queue.is_empty():
		var cur_point = queue.pop_front()
		var head_hash = GameUtils.convert_point_to_hash(cur_point)
		for t_direct in directs:
			var next_point = Vector2(cur_point.x + t_direct.x, \
				cur_point.y + t_direct.y)
			var hash = GameUtils.convert_point_to_hash(next_point)
			var b1 = game.get_point_error(next_point) == GameConst.ERROR.IS_AVAILABLE
			var b2 = distance.get(hash, -1) == -1
			if b1 and b2:
				distance[hash] = distance[head_hash] + unit
				var dist_to_target = next_point.distance_to(target)
				if dist_to_target < min_dist:
					min_dist = dist_to_target
				if dist_to_target <= unit * sqrt(2):
					stop = true
					last_point = next_point
				queue.push_back(next_point)
		if stop:
			break
	return {
		"distance": distance,
		"last_point": last_point
	}

func trace_back(last_point, distance, unit):
	var path = [last_point]
	var cur_point = last_point
	var stop = false
	var directs = GameUtils.get_random_directs(unit)
	while cur_point.distance_to(position) > unit * sqrt(2):
		var cur_distance = distance[GameUtils.convert_point_to_hash(cur_point)]
		for t_direct in directs:
			var next_point = Vector2(cur_point.x + t_direct.x, cur_point.y + t_direct.y)
			var hash = GameUtils.convert_point_to_hash(next_point)
			if distance.get(hash, -1) == cur_distance - unit:
				cur_point = next_point
				path.insert(0, cur_point)
				if cur_point.distance_to(position) < unit * sqrt(2):
					stop = true
				break
		if stop:
			return path
	return path

func add_path(path, target):
	# concatenate path to list points# remove redundant points in path
	var new_path = []
	if len(path) >= 1:
		new_path.append(path[0])
	for idx in range(1, len(path) - 1):
		var pre_point = path[idx - 1]
		var point = path[idx]
		var next_point = path[idx + 1]
		var straight = false
		if pre_point.x == point.x and point.x == next_point.x:
			straight = true
		if pre_point.y == point.y and point.y == next_point.y:
			straight = true
		if not straight:
			new_path.append(path[idx])
	new_path.append(path[len(path) - 1])
	for point in new_path:
		add_point(point)
	add_point(target)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
