extends Node2D


@export var FLOOR_WITDH: int
@export var FLOOR_HEIGHT: int
@export var floor_part_template: PackedScene
@export var floor_node: Node2D
var dragging = false

func _ready():
	init_floor()
	
func init_floor():
	for row in range(FLOOR_HEIGHT):
		for col in range(FLOOR_WITDH):
			var floor_brick = floor_part_template.instantiate()
			var x = col * floor_brick.get_size().x
			var y = row * floor_brick.get_size().y
			floor_brick.position = Vector2(x, y)
			floor_brick.z_index = -1
			floor_node.add_child(floor_brick)

func _on_color_rect_gui_input(event):
	if event is InputEventMouseButton:
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
