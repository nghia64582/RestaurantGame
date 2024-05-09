extends Node2D


func _draw():
	print("Draw MainGame")
	for row in range(0, 50):
		for col in range(0, 50):
			var x = row * 20
			var y = col * 20
			var thick1 = 3 if col % 5 == 0 else 1
			var thick2 = 3 if row % 5 == 0 else 1
			draw_line(Vector2(x, y), Vector2(x + 20, y), Color.BLACK, thick1, false)
			draw_line(Vector2(x, y), Vector2(x, y + 20), Color.BLACK, thick2, false)

func _ready():
	queue_redraw()
