extends Node2D
class_name Waiter



@export var image: Sprite2D
@export var state_lb: Label
@export var component: Control
@export var left_food_node: Node2D
@export var right_food_node: Node2D
@export var mid_food_node: Node2D
@export var waiter_spine: Spine

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
var guest
var id
var state_count_down
# for moving path
var cur_direction
var speed = 500 # pixel per second
var list_points = []
var guest_paid
var radius = 50
var game: MainGame
var next_target: Vector2
var cur_anim: String

func _draw():
	if DevConfig.SHOW_PATH:
		for idx in range(len(list_points)):
			var point = list_points[idx]
			var pre_point = position if idx == 0 else list_points[idx - 1]
			var p1 = Vector2(pre_point.x - position.x, pre_point.y - position.y)
			var p2 = Vector2(point.x - position.x, point.y - position.y)
			draw_line(p1, p2, Color.RED, 5.0, true)

func _ready():
	cur_anim = ""
	sprite_idx = -1
	guest = null
	id = IdGenerator.get_waiter_id()
	update_state(WaiterConst.STATE.IDLE, 0)
	update_z_order()

func _process(delta):
	update_sprite()
	update_food_nodes()
	queue_redraw()
	check_and_move(delta)
	update_state_count_down(delta)
	update_state_label()

func update_state_count_down(delta):
	if state not in [WaiterConst.STATE.PREPARE_TO_IDLE]:
		return
	state_count_down -= delta
	if state_count_down <= 0.0:
		update_next_state()

func update_sprite():
	#sprite_idx += 1
	var textures = get_textures_of_state()
	var anim_st = get_spine_of_state()
	if anim_st == cur_anim:
		return
	cur_anim = anim_st
	waiter_spine.play(anim_st, true)
	#if sprite_idx / 3 >= len(textures):
		#sprite_idx = 0
	#image.texture = textures[sprite_idx / 3]

func check_and_move(delta):
	if len(list_points) == 0:
		return
	next_target = list_points[0]
	var space: float = speed * delta
	var path = Vector2(next_target.x - position.x, next_target.y - position.y)
	if path.length() < space:
		update_position(next_target.x, next_target.y)
		list_points.remove_at(0)
		update_next_target_and_direction()
		if len(list_points) == 0:
			update_next_state()
	else:
		# need to update for steering behavior
		var moving_vector: Vector2 = path / path.length() * space
		#var nearest_obstacle = get_nearest_obstacles()
		#var st = "~~~~~~~~~~~~~~~~~~~~~\n%s\n%s" % [moving_vector, nearest_obstacle]
		#if nearest_obstacle.length() > 1e-2:
			#var side_targets = GameUtils.get_side_targets(position, nearest_obstacle, radius)
			#moving_vector = side_targets[0] - position
			#moving_vector = moving_vector.normalized() * space
		#st += "\n%s" % [moving_vector]
		#if randi_range(1, 100) == 1:
			#print(st)
		var x = position.x + moving_vector.x
		var y = position.y + moving_vector.y
		update_position(x, y)
		# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

func get_nearest_obstacles() -> Vector2:
	var result = Vector2(0, 0)
	var min_dist = 1e9
	for waiter in game.waiters:
		if waiter.is_moving() and waiter.id != id and \
			GameUtils.is_obtascle(position, next_target, waiter.position, radius):
			var dist = waiter.position.distance_to(position)
			if dist < min_dist:
				min_dist = dist
				result = waiter.position
	for guest in game.guests:
		if guest.is_moving() and \
			GameUtils.is_obtascle(position, next_target, guest.position, radius):
			var dist = guest.position.distance_to(position)
			if dist < min_dist:
				min_dist = dist
				result = guest.position
	return result

func is_moving():
	return state in [WaiterConst.STATE.BRING_FOOD_TO_GUEST, \
					WaiterConst.STATE.GO_TO_GUEST,\
					WaiterConst.STATE.GO_TO_GUEST_FOR_PAYMENT,\
					WaiterConst.STATE.GO_TO_IDLE_POS,\
					WaiterConst.STATE.GO_TO_KITCHEN,\
					WaiterConst.STATE.IDLE,\
					WaiterConst.STATE.SEND_ORDER_TO_CHEF]

func get_spine_of_state():
	if state == WaiterConst.STATE.WAIT_FOR_GUEST:
		return "GetOrder"
	if state in [WaiterConst.STATE.IDLE, WaiterConst.STATE.SEND_ORDER_TO_CHEF]:
		return "Idle"
	if cur_direction == GameConst.DIRECT.DOWN:
		if state == WaiterConst.STATE.BRING_FOOD_TO_GUEST:
			return "Walk_FrontWPlate1"
		return "Walk_Front"
	if cur_direction == GameConst.DIRECT.UP:
		if state == WaiterConst.STATE.BRING_FOOD_TO_GUEST:
			return "Walk_BackWPlate"
		return "Walk_Back"
	if cur_direction in [GameConst.DIRECT.RIGHT, GameConst.DIRECT.LEFT]:
		if state == WaiterConst.STATE.BRING_FOOD_TO_GUEST:
			return "Walk_SideWPlate"
		if state in [WaiterConst.STATE.GO_TO_GUEST, WaiterConst.STATE.GO_TO_KITCHEN]:
			return "Walk_FrontWmenu"
		return "Walk_Side"
	return "Walk_Back"
	
func update_food_nodes():
	# display food
	if state == WaiterConst.STATE.BRING_FOOD_TO_GUEST:
		if cur_direction == GameConst.DIRECT.DOWN:
			left_food_node.visible = true
			right_food_node.visible = true
			mid_food_node.visible = false
		elif cur_direction in [GameConst.DIRECT.RIGHT, GameConst.DIRECT.LEFT]:
			mid_food_node.visible = true
			left_food_node.visible = false
			right_food_node.visible = false
		else:
			left_food_node.visible = false
			right_food_node.visible = false
			mid_food_node.visible = false
	else:
		left_food_node.visible = false
		right_food_node.visible = false
		mid_food_node.visible = false

func get_textures_of_state():
	component.scale.x = -abs(component.scale.x) \
		if cur_direction == GameConst.DIRECT.LEFT else \
		abs(component.scale.x)
	if state == WaiterConst.STATE.WAIT_FOR_GUEST:
		return get_order_images
	if state == WaiterConst.STATE.IDLE or len(list_points) == 0:
		return idle_images
	if cur_direction == GameConst.DIRECT.DOWN:
		if state == WaiterConst.STATE.BRING_FOOD_TO_GUEST:
			return walk_front_with_1_plate_images
		return walk_front_images
	if cur_direction == GameConst.DIRECT.UP:
		if state == WaiterConst.STATE.BRING_FOOD_TO_GUEST:
			return walk_back_with_plate_images
		return walk_back_images
	if cur_direction in [GameConst.DIRECT.RIGHT, GameConst.DIRECT.LEFT]:
		if state == WaiterConst.STATE.BRING_FOOD_TO_GUEST:
			return walk_side_with_plate_images
		if state in [WaiterConst.STATE.GO_TO_GUEST, WaiterConst.STATE.GO_TO_KITCHEN]:
			return walk_side_with_menu_images
		return walk_side_images
	return walk_back_images

func update_z_order():
	z_index = position.y + waiter_spine.position.y

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

func update_position(x, y):
	position = Vector2(x, y)
	z_index = y

func update_next_state():
	print("Waiter cur state %s" % [WaiterConst.STATE_NAME[state]])
	if state == WaiterConst.STATE.GO_TO_GUEST:
		update_state(WaiterConst.STATE.WAIT_FOR_GUEST, 0)
	elif state == WaiterConst.STATE.GO_TO_KITCHEN:
		update_state(WaiterConst.STATE.SEND_ORDER_TO_CHEF, 0)
	elif state == WaiterConst.STATE.BRING_FOOD_TO_GUEST:
		update_state(WaiterConst.STATE.SEND_FOOD_TO_GUEST, 0)
	elif state == WaiterConst.STATE.GO_TO_IDLE_POS:
		update_state(WaiterConst.STATE.IDLE, 0)
	elif state == WaiterConst.STATE.GO_TO_GUEST_FOR_PAYMENT:
		update_state(WaiterConst.STATE.CREATE_PAYMENT, 0)
	elif state == WaiterConst.STATE.PREPARE_TO_IDLE:
		update_state(WaiterConst.STATE.GO_TO_IDLE_POS, 0)

func check_change_state(new_state):
	if new_state == WaiterConst.STATE.GO_TO_IDLE_POS:
		find_path(Vector2(300, 400))
	elif new_state == WaiterConst.STATE.WAIT_FOR_GUEST:
		guest.update_state(GuestConst.STATE.PICK_FOOD, 3)
	elif new_state == WaiterConst.STATE.SEND_ORDER_TO_CHEF:
		var order = guest.order
		var kitchen = order.kitchen
		kitchen.main_chef.start_cooking()
		kitchen.waiter = self
	elif new_state == WaiterConst.STATE.SEND_FOOD_TO_GUEST:
		update_state(WaiterConst.STATE.PREPARE_TO_IDLE, 0.3)
		guest.update_state(GuestConst.STATE.HAVE_MEAL, 3 * len(guest.order.foods_id))
	elif new_state == WaiterConst.STATE.CREATE_PAYMENT:
		var guest = guest_paid
		if guest == null:
			return
		var table = guest.table
		guest.update_state(GuestConst.STATE.LEAVE, 0)
		update_state(WaiterConst.STATE.PREPARE_TO_IDLE, 0.3)
		table.update_state(TableConst.STATE.FREE)

func update_state(new_state, count_down):
	state_count_down = count_down
	state = new_state
	check_change_state(new_state)

func update_state_label():
	state_lb.text = "Id %s\n%s" % [id, WaiterConst.STATE_NAME[state]]

# FINDING PATH METHODS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
func find_path(target: Vector2):
	var t0 = Time.get_ticks_msec()
	var unit = PathFinder.UNIT
	var result = PathFinder.find_path(position, target)
	var last_point
	var distance
	if result != null:
		distance = result["distance"]
		last_point = result["last_point"]
	else:
		result = bfs(target, unit)
		distance = result["distance"]
		last_point = result["last_point"]
	var t1 = Time.get_ticks_msec()
	# traceback to find the shortest path
	var path = trace_back(last_point, distance, unit)
	add_path(path, target)
	update_next_target_and_direction()

func bfs(target, unit):
	# Use BFS to find path to all available points in game
	var queue = [position]
	var distance = {GameUtils.convert_point_to_hash(position): 0}
	var stop = false
	var count = 0
	var min_dist = 100000
	var last_point = Vector2(0, 0)
	var directs = GameUtils.get_random_directs(unit)
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
