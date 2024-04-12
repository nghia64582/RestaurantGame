extends Control

@export var chef_template: PackedScene
@export var chef_node: Node2D
@export var components: Control
@export var waiter_pos: Node2D
var main_chef
var id
var waiter_id

func _ready():
	update_z_order()
	init_chef()
	init_info()

func init_info():
	id = IdGenerator.get_kitchen_id()

func init_chef():
	main_chef = chef_template.instantiate()
	var x = chef_node.position.x * components.scale.x
	var y = chef_node.position.y * components.scale.x
	main_chef.position = Vector2(x, y)
	main_chef.z_index = 1
	add_child(main_chef)

func update_z_order():
	z_index = position.y
