extends Node2D

@export var food_template: PackedScene
@export var guest_template: PackedScene
@export var N_FOODS: int
@export var N_GUESTS: int
@export var component: Control
@export var guest_nodes: Array[Node2D] = []
@export var food_nodes: Array[Node2D] = []

var guests
var state
var id
var game

func _ready():
	guests = []
	state = TableConst.STATE.FREE
	id = IdGenerator.get_table_id()
	update_z_order()
	init_random_foods_and_drinks()

func add_food(food_id, idx):
	var food = food_template.instantiate()
	var x = food_nodes[idx].position.x * component.scale.x
	var y = food_nodes[idx].position.y * component.scale.x
	food.position = Vector2(x, y)
	food.set_random_type()
	food.z_index = 4096
	add_child(food)

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
