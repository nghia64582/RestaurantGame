extends Control

@export var chef_template: PackedScene
@export var chef_node: Node2D
@export var components: Control
var main_chef

func _ready():
	main_chef = chef_template.instantiate()
	var x = chef_node.position.x * components.scale.x
	var y = chef_node.position.y * components.scale.x
	main_chef.position = Vector2(x, y)
	add_child(main_chef)
