extends Node2D
class_name MainGame


@export var FLOOR_WITDH: int
@export var FLOOR_HEIGHT: int
@export var N_SIDE_WALK_BRICKS: int
@export var floor_node: Node2D
@export var side_walk_brick_template: PackedScene
@export var floor_part_template: PackedScene
@export var guest_template: PackedScene
@export var chef_template: PackedScene
@export var kitchen_template: PackedScene
@export var waiter_template: PackedScene
@export var table_template: PackedScene
@export var component_node: Node2D
@export var side_walk_node: Node2D
@export var table_row_nodes: Array[Node2D] = []
@export var cheat_btns: Node2D
@export var walls: Array[ColorRect] = []
@export var level_box: ColorRect
@export var tf_spine_name: TextEdit
@export var demo_spine: Spine

@export_group("kitchen nodes")
@export var kitchen_nodes: Array[Node2D] = []
@export var N_KITCHENS = 4
@export_group("Game data")
@export var cash_lb: Label
@export var gem_lb: Label
@export var level_lb: Label

var dragging = false
var guest_generator_cool_down
var kitchens: Array[Kitchen] = []
var tables: Array[Table] = []
var guests: Array[Guest] = []
var waiters: Array[Waiter] = []
var bricks: Array[Node2D] = []
var game_data: GameData
var floor_sample: Node2D
var auto_save_count_down: float

func _ready():
	GameConfig.load_config()
	load_game_data()
	init_game()

func _process(delta):
	check_generating_guests(delta)
	check_auto_save(delta)
	
func init_game():
	init_info()
	init_floor()
	init_kitchens()
	init_tables()
	init_waiter()
	init_path_finder()

func load_game_data():
	game_data = GameData.new()
	game_data.load_data()
	game_data.set_game(self)
	update_ui_game_data()
	
func reset_game_data():
	game_data.reset_game_data()
	clean_game()
	init_game()
	cheat_btns.visible = false

func update_ui_game_data():
	cash_lb.text = str(game_data.cash)
	level_lb.text = GameUtils.get_level_text(game_data.exp)

func check_auto_save(delta):
	auto_save_count_down -= delta
	if auto_save_count_down <= 0:
		auto_save_count_down = 5
		save_game()

func init_info():
	auto_save_count_down = 5
	guest_generator_cool_down = 5

func init_floor():
	bricks = []
	floor_sample = floor_part_template.instantiate()
	for row in range(FLOOR_HEIGHT):
		for col in range(FLOOR_WITDH):
			var floor_brick = floor_part_template.instantiate()
			var x = col * floor_brick.get_size().x
			var y = row * floor_brick.get_size().y
			floor_brick.position = Vector2(x, y)
			floor_brick.z_index = -1
			bricks.append(floor_brick)
			floor_node.add_child(floor_brick)
	floor_node.init(self)
	for idx in range(N_SIDE_WALK_BRICKS):
		var side_walk_brick = side_walk_brick_template.instantiate()
		var x = 0
		var y = idx * side_walk_brick.get_height()
		side_walk_brick.position = Vector2(x, y)
		side_walk_brick.z_index = -1
		side_walk_node.add_child(side_walk_brick)

func init_kitchens():
	for idx in range(len(game_data.kitchen_pos)):
		var kitchen_data = game_data.kitchen_pos[idx]
		var kitchen = kitchen_template.instantiate()
		var kit_pos: Vector2 = Vector2(kitchen_data["x"], kitchen_data["y"])
		kitchen.game = self
		kitchen.position = kit_pos
		kitchens.append(kitchen)
		floor_node.add_child(kitchen)
		var waiter_node = kitchen.waiter_node
		var waiter_x = kit_pos.x + waiter_node.position.x
		var waiter_y = kit_pos.y + waiter_node.position.y
		kitchen.waiter_pos = Vector2(waiter_x, waiter_y)

func find_first_x(row: int):
	var row_y = table_row_nodes[row].position.y
	var first_x: float = table_row_nodes[row].position.x
	var count = 0
	for table in tables:
		if abs(row_y - table.position.y) < 1:
			count += 1
			first_x = max(first_x, (table.position.x + table.collide_area.size.x + 150))
	return first_x

func add_table(row: int, type: int):
	var first_x = find_first_x(row)
	var row_y = table_row_nodes[row].position.y
	init_table(Vector2(first_x, row_y), type)
	init_floor()

func init_tables():
	for table_data in game_data.tables:
		init_table(Vector2(table_data["x"], table_data["y"]), table_data["type"])

func init_table(pos: Vector2, type):
	var table = table_template.instantiate()
	table.position = pos
	tables.append(table)
	table.game = self
	table.init_type(type)
	floor_node.add_child(table)
	
	if PathFinder.game != null:
		PathFinder.init_point(table.position)

func init_waiter():
	for idx in range(game_data.n_waiter):
		var waiter = waiter_template.instantiate()
		waiter.game = self
		waiter.update_position(idx * 200 + 300, 400)
		waiters.append(waiter)
		floor_node.add_child(waiter)

func init_path_finder():
	PathFinder.init(self)

func add_random_guest():
	var guest = guest_template.instantiate()
	guest.game = self
	guest.start_time = Time.get_ticks_msec()
	var free_table = find_free_table()
	if free_table == null:
		return
	guests.append(guest)
	guest.position = Vector2(100, 900)
	guest.table = free_table
	guest.find_path(free_table.position)
	free_table.state = TableConst.STATE.USED
	floor_node.add_child(guest)

func clean_game():
	for kitchen in kitchens:
		floor_node.remove_child(kitchen)
	for table in tables:
		floor_node.remove_child(table)
	for guest in guests:
		floor_node.remove_child(guest)
	for waiter in waiters:
		floor_node.remove_child(waiter)
	for brick in bricks:
		floor_node.remove_child(brick)
	kitchens = []
	tables = []
	guests = []
	waiters = []
	bricks = []

func do_guest_sit_on_table(guest: Guest):
	guest.pre_pos = guest.position
	guest.pre_z_index = guest.z_index
	floor_node.remove_child(guest)
	guest.table.add_child(guest)
	guest.table.set_guest_pos(guest, 0)

func do_guest_leave_table(guest: Guest):
	print("Guest cycle time : " + str(Time.get_ticks_msec() - guest.start_time))
	guest.table.remove_child(guest)
	floor_node.add_child(guest)
	guest.position = guest.pre_pos + Vector2(50, 0)
	guest.z_index = guest.pre_z_index
	guest.find_path(Vector2(100, 900))
	finished_guest_order(guest.order)

func finished_guest_order(order: Order):
	game_data.finished_guest_order(order)

func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				floor_node.scale *= 1.05
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				floor_node.scale /= 1.05
				if floor_node.scale.x < 1.27 and DevConfig.LIMIT_SCALE_OUT:
					floor_node.scale = Vector2(1.27, 1.27)
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dragging = true
		else:
			dragging = false
	if event is InputEventMouseMotion:
		if dragging:
			var delta = event.relative
			var pre_x = floor_node.position.x
			var pre_y = floor_node.position.y
			floor_node.position = Vector2(pre_x + delta.x, pre_y + \
				(delta.y if DevConfig.UP_DOWN_DRAG else 0))

func find_free_table() -> Table:
	var result = []
	for table in tables:
		if table.state == TableConst.STATE.FREE:
			result.append(table)
	if len(result) == 0:
		return null
	else:
		var idx = randi_range(0, len(result) - 1)
		return result[idx]

func find_idle_waiter() -> Waiter:
	for waiter in waiters:
		if waiter.state in [WaiterConst.STATE.IDLE, WaiterConst.STATE.PREPARE_TO_IDLE]:
			return waiter
	return null

func find_free_kitchen():
	var result = []
	for kitchen in kitchens:
		if kitchen.main_chef.state == ChefConst.STATE.WAIT_FOR_ORDER:
			result.append(kitchen)
	if len(result) == 0:
		return null
	else:
		var idx = randi_range(0, len(result) - 1)
		return result[idx]

func check_generating_guests(delta: float):
	guest_generator_cool_down -= delta
	if guest_generator_cool_down < 0:
		guest_generator_cool_down = 5
		add_random_guest()

func call_waiter_for_menu(guest: Guest):
	var idle_waiter = find_idle_waiter()
	if idle_waiter == null:
		return false
	idle_waiter.find_path(guest.table.position)
	idle_waiter.update_state(WaiterConst.STATE.GO_TO_GUEST, 0)
	idle_waiter.guest = guest
	guest.waiter = idle_waiter
	return true

func call_waiter_for_payment(guest: Guest):
	var idle_waiter = find_idle_waiter()
	if idle_waiter == null:
		return false
	idle_waiter.update_state(WaiterConst.STATE.GO_TO_GUEST_FOR_PAYMENT, 0)
	idle_waiter.guest_paid = guest
	idle_waiter.find_path(guest.table.position)
	return true

func has_point(point: Vector2):
	return point.x > 10 and point.y > 10 and \
		point.x < FLOOR_WITDH * floor_sample.get_size().x and \
		point.y < FLOOR_HEIGHT * floor_sample.get_size().y

func get_point_error(point: Vector2):
	if not has_point(point):
		return GameConst.ERROR.IS_OUTSIDE_MAP
	for table in tables:
		if table.has_point(point):
			return GameConst.ERROR.IS_INSIDE_TABLE
	for kitchen in kitchens:
		if kitchen.has_point(point):
			return GameConst.ERROR.IS_INSIDE_KITCHEN
	for wall in walls:
		if wall.get_rect().has_point(point):
			return GameConst.ERROR.IS_INSIDE_WALL
	return GameConst.ERROR.IS_AVAILABLE

func add_table_by_type(type: int):
	var min_first_x = 1e4
	var key_row = 0
	for row in range(2):
		var first_x = find_first_x(row)
		if first_x < min_first_x:
			min_first_x = first_x
			key_row = row
	add_table(key_row, type)

func add_area():
	FLOOR_WITDH += 1
	init_floor()

func save_game():
	game_data.kitchen_pos = []
	game_data.tables = []
	for kitchen in kitchens:
		game_data.kitchen_pos.append({
			"x": kitchen.position.x,
			"y": kitchen.position.y
		})
	for table in tables:
		var table_data = {
			"type": table.type,
			"x": table.position.x,
			"y": table.position.y
		}
		game_data.tables.append(table_data)
	game_data.n_waiter = len(waiters)
	game_data.n_width = FLOOR_WITDH
	game_data.n_height = FLOOR_HEIGHT
	GameUtils.save_game(game_data.get_dict())

func add_kitchen():
	pass

func _on_btn_add_table_1_pressed():
	add_table_by_type(TableConst.TYPE.SMALL)

func _on_btn_add_table_2_pressed():
	add_table_by_type(TableConst.TYPE.BIG)

func _on_btn_add_area_pressed():
	add_area()

func _on_btn_cheat_pressed():
	cheat_btns.visible = not cheat_btns.visible

func _on_btn_add_waiter_pressed():
	var waiter = waiter_template.instantiate()
	waiter.game = self
	waiter.update_position(100, 100)
	waiters.append(waiter)
	floor_node.add_child(waiter)

func _on_btn_grid_pressed():
	init_floor()
	DevConfig.SHOW_GRID = not DevConfig.SHOW_GRID

func _on_btn_path_pressed():
	init_floor()
	DevConfig.SHOW_PATH = not DevConfig.SHOW_PATH

func _on_btn_reset_pressed():
	reset_game_data()

func _on_btn_play_spine_pressed():
	var txt = tf_spine_name.text
	print(txt)
	demo_spine.play(txt, true)
