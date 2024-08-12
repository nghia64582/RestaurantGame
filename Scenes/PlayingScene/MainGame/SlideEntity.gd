extends Node
class_name SlideEntity

var speed_x: int
var dragging: bool
func _ready():
	speed_x = 0
	dragging = false

func on_slide(delta_x):
	pass
