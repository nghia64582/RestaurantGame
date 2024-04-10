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
@export var big_table_template: PackedScene
@export var small_table_template: PackedScene
@export var component_node: Node2D
@export var side_walk_node: Node2D

@export_group("kitchen nodes")
@export var kitchen_nodes: Array[Node2D] = []
@export var N_KITCHENS = 4
@export_group("big table nodes")
@export var big_table_nodes: Array[Node2D] = []
@export var N_BIG_TABLES = 4
@export_group("small table nodes")
@export var small_table_nodes: Array[Node2D] = []
@export var N_SMALL_TABLES = 4

var dragging = false
var guest_generator_cool_down
var kitchens = []
var big_tables = []
var small_tables = []
var guests = []
var waiters = []

func _ready():
	init_info()
	init_floor()
	init_kitchens()
	init_big_tables()
	init_small_tables()
	init_waiter()

func _process(delta):
	check_generating_guests(delta)
	check_waiting_guests()
	
func check_generating_guests(delta):
	guest_generator_cool_down -= delta
	if guest_generator_cool_down < 0:
		guest_generator_cool_down = 5
		add_random_guest()
		
func check_waiting_guests():
	var waiting_guest = find_waiting_for_waiter_guest()
	if waiting_guest == null:
		return
	var free_waiter = find_free_waiter()
	if free_waiter == null:
		return
	free_waiter.add_point(waiting_guest.position)
	free_waiter.update_next_state()

func init_info():
	guest_generator_cool_down = 1

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
		kitchen.position = Vector2(x, y)
		kitchens.append(kitchen)
		floor_node.add_child(kitchen)

func init_big_tables():
	for idx in range(N_BIG_TABLES):
		var big_table = big_table_template.instantiate()
		var x = big_table_nodes[idx].position.x * get_floor_scale()
		var y = big_table_nodes[idx].position.y * get_floor_scale()
		big_table.position = Vector2(x, y)
		big_tables.append(big_table)
		floor_node.add_child(big_table)

func init_small_tables():
	for idx in range(N_SMALL_TABLES):
		var small_table = small_table_template.instantiate()
		var x = small_table_nodes[idx].position.x * get_floor_scale()
		var y = small_table_nodes[idx].position.y * get_floor_scale()
		small_table.position = Vector2(x, y)
		small_tables.append(small_table)
		floor_node.add_child(small_table)

func init_waiter():
	var waiter = waiter_template.instantiate()
	waiter.update_position(100, 100)
	waiters.append(waiter)
	floor_node.add_child(waiter)

func add_random_guest():
	var guest = guest_template.instantiate()
	var free_table = find_free_table()
	if free_table == null:
		return
	guests.append(guest)
	guest.position = Vector2(10, 400)
	guest.add_point(free_table.position)
	free_table.state = TableConst.STATE.USED
	floor_node.add_child(guest)

func get_floor_scale():
	return component_node.scale.x

func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				floor_node.scale *= 1.1
			# zoom out
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				floor_node.scale /= 1.1
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			dragging = true
		else:
			dragging = false
	if event is InputEventMouseMotion:
		if dragging:
			var delta = event.relative
			var pre_x = floor_node.position.x
			var pre_y = floor_node.position.y
			floor_node.position = Vector2(pre_x + delta.x, pre_y + delta.y)

func find_free_table():
	for table in small_tables:
		if table.state == TableConst.STATE.FREE:
			return table
	for table in big_tables:
		if table.state == TableConst.STATE.FREE:
			return table
		return null

func find_waiting_for_waiter_guest():
	for guest in guests:
		if guest.work_state == GuestConst.WORK_STATE.WAIT_FOR_WAITER:
			return guest
	return null

func find_free_waiter():
	for waiter in waiters:
		if waiter.work_state == WaiterConst.WORK_STATE.IDLE:
			return waiter
	return null
