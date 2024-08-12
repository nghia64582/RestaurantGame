extends Node2D
class_name Guest

var sprite_idx
var state
var id
var sprite_type
var table
var waiter
# for moving path
var cur_direction
var speed = 400 # pixel per second
var list_points = []
var state_count_down
var max_count_down
var order
var react_anim
var game: MainGame
var pre_pos
var pre_z_index
var called_waiter
var next_target: Vector2
var radius = 50
var start_time
@export var state_lb: Label
@export var image: Sprite2D
@export var progress_bar: ProgressBar
@export var guest_spine_factory_template: PackedScene
@export var spine_list: Array[Spine]
var main_spine: Spine
var cur_anim: String
static var guest_spine_factory: GuestSpineFactory

func _draw():
	if DevConfig.SHOW_PATH:
		for idx in range(len(list_points)):
			var point = list_points[idx]
			var pre_point = position if idx == 0 else list_points[idx - 1]
			var p1 = Vector2(pre_point.x - position.x, pre_point.y - position.y)
			var p2 = Vector2(point.x - position.x, point.y - position.y)
			draw_line(p1, p2, Color.RED, 5.0, true)

func _ready():
	update_state(GuestConst.STATE.GO_TO_TABLE, 0)
	sprite_idx = -1
	called_waiter = false
	id = IdGenerator.get_guest_id()
	update_z_order()
	init_spine()
	
func init_spine():
	cur_anim = ""
	var spine_id = randi_range(1, 7)
	main_spine = spine_list[spine_id]
	for spine in spine_list:
		spine.visible = false
	main_spine.visible = true

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
	var anim_st = get_current_anim()
	if anim_st == cur_anim:
		return
	cur_anim = anim_st
	main_spine.play(anim_st, true)

func get_current_anim():
	if state == GuestConst.STATE.GO_TO_TABLE:
		return "stand and Bored"
	if state == GuestConst.STATE.WAIT_FOR_WAITER:
		return "Call Waiters"
	if state == GuestConst.STATE.PICK_FOOD:
		return "Read Menu"
	if state == GuestConst.STATE.WAIT_FOR_MEAL:
		return "Waiting for the food 1"
	if state == GuestConst.STATE.HAVE_MEAL:
		return "Eat"
	if state == GuestConst.STATE.REACT:
		return "Satisfied1"
	if state == GuestConst.STATE.LEAVE:
		return "stand and Bored"
	return "stand and Bored"
	
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
		if waiter.is_moving() and \
			GameUtils.is_obtascle(position, next_target, waiter.position, radius):
			var dist = waiter.position.distance_to(position)
			if dist < min_dist:
				min_dist = dist
				result = waiter.position
	for guest in game.guests:
		if guest.id != id and guest.is_moving() and \
			GameUtils.is_obtascle(position, next_target, guest.position, radius):
			var dist = guest.position.distance_to(position)
			if dist < min_dist:
				min_dist = dist
				result = guest.position
	return result

func is_moving():
	return state in [GuestConst.STATE.GO_TO_TABLE, GuestConst.STATE.LEAVE]

#func get_textures_of_state():
	#if state == GuestConst.STATE.GO_TO_TABLE:
		#return stand_and_wait_images
	#if state == GuestConst.STATE.WAIT_FOR_WAITER:
		#return call_waiter_images
	#if state == GuestConst.STATE.PICK_FOOD:
		#return read_menu_images
	#if state == GuestConst.STATE.WAIT_FOR_MEAL:
		#return waiting_for_food_1_images
	#if state == GuestConst.STATE.HAVE_MEAL:
		#return eat_images
	#if state == GuestConst.STATE.REACT:
		#return react_anim
	#if state == GuestConst.STATE.LEAVE:
		#return stand_and_wait_images
	#return stand_and_wait_images

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
	print("Guest cur state %s" % [GuestConst.STATE_NAME[state]])
	if state == GuestConst.STATE.GO_TO_TABLE:
		update_state(GuestConst.STATE.WAIT_FOR_WAITER, 0)
	elif state == GuestConst.STATE.PICK_FOOD:
		update_state(GuestConst.STATE.WAIT_FOR_MEAL, 0)
	elif state == GuestConst.STATE.HAVE_MEAL:
		update_state(GuestConst.STATE.REACT, 0)
	elif state == GuestConst.STATE.LEAVE:
		update_state(GuestConst.STATE.LEFT, 0)

func update_state_label():
	state_lb.text = "Id %d\n%s\nT %.2f" % [id, GuestConst.STATE_NAME[state]\
		, state_count_down]

func update_state(new_state, count_down):
	check_change_state(new_state)
	state = new_state
	state_count_down = count_down
	max_count_down = count_down

func check_change_state(new_state):
	if new_state == GuestConst.STATE.REACT:
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
	waiter.update_state(WaiterConst.STATE.GO_TO_KITCHEN, 0)
	print("Guest %d picked food %s, waiter %d, kitchen %d" %
		[id, str(order.foods_id), waiter.id, order.kitchen])

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
	# concatenate path to list points
	# remove redundant points in path
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
