extends Node2D


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

@export_group("kitchen nodes")
@export var kitchen_nodes: Array[Node2D] = []
@export var N_KITCHENS = 4
@export_group("big table nodes")
@export var big_table_nodes: Array[Node2D] = []
@export_group("small table nodes")
@export var small_table_nodes: Array[Node2D] = []

var dragging = false
var guest_generator_cool_down
var kitchens = []
var tables = []
var guests = []
var waiters = []

func _ready():
	init_info()
	init_floor()
	init_kitchens()
	init_tables()
	init_waiter()

func _process(delta):
	check_generating_guests(delta)

func init_info():
	guest_generator_cool_down = 1
	floor_node.scale = Vector2(1.27, 1.27)
	floor_node.position = Vector2(147, 41)

func init_floor():
	for row in range(FLOOR_HEIGHT):
		for col in range(FLOOR_WITDH):
			var floor_brick = floor_part_template.instantiate()
			var x = col * floor_brick.get_size().x
			var y = row * floor_brick.get_size().y
			floor_brick.position = Vector2(x, y)
			floor_brick.z_index = -1
			floor_node.add_child(floor_brick)
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
		var x = kitchen_nodes[idx].position.x * get_floor_scale()
		var y = kitchen_nodes[idx].position.y * get_floor_scale()
		kitchen.game = self
		kitchen.position = Vector2(x, y)
		kitchens.append(kitchen)
		floor_node.add_child(kitchen)

func init_tables():
	for idx in range(len(big_table_nodes)):
		init_table(big_table_nodes[idx], TableConst.TYPE.BIG)
	for idx in range(len(small_table_nodes)):
		init_table(small_table_nodes[idx], TableConst.TYPE.SMALL)

func init_table(node, type):
	var table = table_template.instantiate()
	var x = node.position.x * get_floor_scale()
	var y = node.position.y * get_floor_scale()
	table.position = Vector2(x, y)
	tables.append(table)
	table.game = self
	table.init_type(type)
	floor_node.add_child(table)

func init_waiter():
	for idx in range(2):
		var waiter = waiter_template.instantiate()
		waiter.game = self
		waiter.update_position(idx * 50 + 50, 100)
		waiters.append(waiter)
		floor_node.add_child(waiter)

func add_random_guest():
	var guest = guest_template.instantiate()
	guest.game = self
	var free_table = find_free_table()
	if free_table == null:
		return
	guests.append(guest)
	guest.position = Vector2(10, 300)
	guest.table = free_table
	guest.add_point(free_table.position)
	free_table.state = TableConst.STATE.USED
	floor_node.add_child(guest)

func do_guest_sit_on_table(guest):
	guest.pre_pos = guest.position
	guest.pre_z_index = guest.z_index
	floor_node.remove_child(guest)
	guest.table.add_child(guest)
	guest.table.set_guest_pos(guest, 0)

func do_guest_leave_table(guest):
	guest.table.remove_child(guest)
	floor_node.add_child(guest)
	guest.position = guest.pre_pos
	guest.z_index = guest.pre_z_index
	guest.add_point(Vector2(10, 250))

func get_floor_scale():
	return component_node.scale.x

func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				floor_node.scale *= 1.01
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				floor_node.scale /= 1.01
				if floor_node.scale.x < 1.27:
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
			floor_node.position = Vector2(pre_x + delta.x, pre_y)

func find_free_table():
	var result = []
	for table in tables:
		if table.state == TableConst.STATE.FREE:
			result.append(table)
	if len(result) == 0:
		return null
	else:
		var idx = randi_range(0, len(result) - 1)
		return result[idx]

func find_idle_waiter():
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

func check_generating_guests(delta):
	guest_generator_cool_down -= delta
	if guest_generator_cool_down < 0:
		guest_generator_cool_down = 5
		add_random_guest()

func call_waiter_for_menu(guest):
	var idle_waiter = find_idle_waiter()
	if idle_waiter == null:
		return false
	idle_waiter.add_point(guest.table.position)
	idle_waiter.update_next_state()
	idle_waiter.guest = guest
	guest.waiter = idle_waiter
	return true

func call_waiter_for_payment(guest):
	var idle_waiter = find_idle_waiter()
	if idle_waiter == null:
		return false
	idle_waiter.update_state(WaiterConst.STATE.GO_TO_GUEST_FOR_PAYMENT)
	idle_waiter.guest_paid = guest
	idle_waiter.add_point(guest.table.position)
	return true
