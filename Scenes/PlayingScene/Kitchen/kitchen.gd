extends Control
class_name Kitchen

@export var chef_template: PackedScene
@export var chef_node: Node2D
@export var components: Control
@export var waiter_node: Node2D
@export var collide_area: ColorRect
var main_chef
var id
var waiter
var game: MainGame
var waiter_pos

func _draw():
	if DevConfig.SHOW_GRID:
		var rect = collide_area.get_rect()
		draw_rect(Rect2(rect.position, Vector2(rect.size.x * components.scale.x, \
			rect.size.y * components.scale.y)), Color.PURPLE, false, 1.0)

func _ready():
	queue_redraw()
	update_z_order()
	init_chef()
	init_info()

func init_info():
	id = IdGenerator.get_kitchen_id()

func init_chef():
	main_chef = chef_template.instantiate()
	var x = chef_node.position.x * components.scale.x
	var y = chef_node.position.y * components.scale.x
	main_chef.kitchen = self
	main_chef.position = Vector2(x, y)
	main_chef.z_index = 1
	add_child(main_chef)

func update_z_order():
	z_index = position.y

func has_point(point: Vector2):
	var up_left = position + collide_area.get_rect().position * components.scale.x
	var size = collide_area.get_rect().size * components.scale.x
	return Rect2(up_left, size).has_point(point)
