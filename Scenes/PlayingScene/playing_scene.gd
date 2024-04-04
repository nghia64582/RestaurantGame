extends Node2D


@export var FLOOR_WITDH: int
@export var FLOOR_HEIGHT: int
@export var floor_node: Node2D
@export var floor_part_template: PackedScene
@export var guest_template: PackedScene
@export var chef_template: PackedScene
@export var kitchen_template: PackedScene
@export var waiter_template: PackedScene
@export var big_table_template: PackedScene
@export var small_table_template: PackedScene
@export var component_node: Node2D

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
var kitchens = []
var big_tables = []
var small_tables = []
var guests = []

func _ready():
	init_floor()
	init_kitchens()
	init_big_tables()
	init_small_tables()
	init_guests()
	
func init_floor():
	for row in range(FLOOR_HEIGHT):
		for col in range(FLOOR_WITDH):
			var floor_brick = floor_part_template.instantiate()
			var x = col * floor_brick.get_size().x
			var y = row * floor_brick.get_size().y
			floor_brick.position = Vector2(x, y)
			floor_brick.z_index = -1
			floor_node.add_child(floor_brick)

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

func init_guests():
	var guest = guest_template.instantiate()
	guest.position = Vector2(100, 100)
	guests.append(guest)
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
