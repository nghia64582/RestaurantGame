extends Node2D
class_name Table

@export var food_template: PackedScene
@export var guest_template: PackedScene

# big table var
@export var bt_N_FOODS: int
@export var bt_N_GUESTS: int
@export var bt_component: Control
@export var bt_guest_nodes: Array[Node2D] = []
@export var bt_food_nodes: Array[Node2D] = []
@export var bt_collide_area: ColorRect
# small table 
@export var st_N_FOODS: int
@export var st_N_GUESTS: int
@export var st_component: Control
@export var st_guest_nodes: Array[Node2D] = []
@export var st_food_nodes: Array[Node2D] = []
@export var st_collide_area: ColorRect

var N_FOODS: int
var N_GUESTS: int
var component: Control
var guest_nodes: Array[Node2D] = []
var food_nodes: Array[Node2D] = []
var collide_area: ColorRect

var guests
var state
var id
var game: MainGame
var foods = []
var type

func _draw():
	if DevConfig.SHOW_GRID:
		var rect = collide_area.get_rect()
		var pos = rect.position
		var width = rect.size.x
		var height = rect.size.y
		draw_rect(Rect2(pos * component.scale.x, Vector2(width * component.scale.x, \
			height * component.scale.y)), Color.CYAN, false, 5.0)
	draw_string(ThemeDB.fallback_font, collide_area.get_rect().size / 2 * \
		component.scale.x, str(id))

func _ready():
	guests = []
	foods = []
	state = TableConst.STATE.FREE
	id = IdGenerator.get_table_id()
	update_z_order()

func init_type(n_type):
	type = n_type
	if type == TableConst.TYPE.BIG:
		N_FOODS = bt_N_FOODS
		N_GUESTS = bt_N_GUESTS
		component = bt_component
		guest_nodes = bt_guest_nodes
		food_nodes = bt_food_nodes
		collide_area = bt_collide_area
		st_component.visible = false
		bt_component.visible = true
	elif type == TableConst.TYPE.SMALL:
		N_FOODS = st_N_FOODS
		N_GUESTS = st_N_GUESTS
		component = st_component
		guest_nodes = st_guest_nodes
		food_nodes = st_food_nodes
		collide_area = st_collide_area
		bt_component.visible = false
		st_component.visible = true
	queue_redraw()

func add_food(food_id, idx):
	var food = food_template.instantiate()
	var x = food_nodes[idx].position.x * component.scale.x
	var y = food_nodes[idx].position.y * component.scale.x
	food.position = Vector2(x, y)
	food.set_random_type()
	food.z_index = 4096
	add_child(food)
	foods.append(food)

func set_guest_pos(guest, idx):
	var x = guest_nodes[idx].position.x * component.scale.x
	var y = guest_nodes[idx].position.y * component.scale.x
	guest.position = Vector2(x, y)
	if idx < N_GUESTS / 2:
		guest.z_index = -1

func init_random_foods_and_drinks():
	pass

func init_guests():
	for idx in range(N_GUESTS):
		var guest = guest_template.instantiate()
		var x = guest_nodes[idx].position.x * component.scale.x
		var y = guest_nodes[idx].position.y * component.scale.x
		guest.position = Vector2(x, y)
		add_child(guest)
		if idx < N_GUESTS / 2:
			guest.z_index = -1

func update_z_order():
	z_index = position.y

func update_state(new_state):
	state = new_state
	
func update_foods(food_ids):
	for idx in range(len(food_ids)):
		var food_id = food_ids[idx]
		add_food(food_id, idx)

func remove_food_with_idx(idx):
	var last_idx = len(foods) - 1
	if last_idx < 0:
		return
	remove_child(foods[last_idx])
	foods.remove_at(last_idx)

func has_point(point: Vector2):
	var up_left = position + collide_area.get_rect().position * component.scale.x
	var size = collide_area.get_rect().size * component.scale.x
	return Rect2(up_left, size).has_point(point)
