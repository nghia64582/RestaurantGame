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
var walls = []
var game_data: GameData
var floor_sample: Node2D

func test():
	print(GameUtils.is_obtascle(Vector2(0, 0), Vector2(10, 0), Vector2(5, 1), 1))
	print(GameUtils.distance_point_to_line(Vector2(0, 0), Vector2(1, -1), Vector2(1, 1)))
	print(GameUtils.get_side_targets(Vector2(0, 0), Vector2(10, 0), 1))

func _ready():
	#test()
	#return
	GameConfig.load_config()
	init_info()
	init_floor()
	init_kitchens()
	init_tables()
	init_waiter()
	load_game_data()
	init_path_finder()

func load_game_data():
	game_data = GameData.new()
	game_data.init(self)
	update_ui_game_data()

func update_ui_game_data():
	cash_lb.text = str(game_data.cash)
	level_lb.text = GameUtils.get_level_text(game_data.exp)

func _process(delta):
	check_generating_guests(delta)

func init_info():
	guest_generator_cool_down = 1
	floor_node.scale = Vector2(1.27, 1.27)

func init_floor():
	for node in bricks:
		floor_node.remove_child(node)
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
	for idx in range(N_KITCHENS):
		var kitchen = kitchen_template.instantiate()
		var kit_pos: Vector2 = kitchen_nodes[idx].position
		kitchen.game = self
		kitchen.position = kitchen_nodes[idx].position
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
	for idx in range(3):
		for row in range(2):
			var type = randi_range(0, 1)
			add_table(row, type)

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
	for idx in range(2):
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
	var free_table = find_free_table()
	if free_table == null:
		return
	guests.append(guest)
	guest.position = Vector2(100, 900)
	guest.table = free_table
	guest.find_path(free_table.position)
	free_table.state = TableConst.STATE.USED
	floor_node.add_child(guest)

func do_guest_sit_on_table(guest: Guest):
	guest.pre_pos = guest.position
	guest.pre_z_index = guest.z_index
	floor_node.remove_child(guest)
	guest.table.add_child(guest)
	guest.table.set_guest_pos(guest, 0)

func do_guest_leave_table(guest: Guest):
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
		if waiter.state in [WaiterConst.STATE.IDLE]:
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
	idle_waiter.update_state(WaiterConst.STATE.GO_TO_GUEST)
	idle_waiter.guest = guest
	guest.waiter = idle_waiter
	return true

func call_waiter_for_payment(guest: Guest):
	var idle_waiter = find_idle_waiter()
	if idle_waiter == null:
		return false
	idle_waiter.update_state(WaiterConst.STATE.GO_TO_GUEST_FOR_PAYMENT)
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
