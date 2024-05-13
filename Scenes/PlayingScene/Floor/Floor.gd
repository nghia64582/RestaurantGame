extends Node2D


var game: MainGame
func _draw():
	print("Draw MainGame")
	for row in range(0, 50):
		for col in range(0, 50):
			var x = row * 20
			var y = col * 20
			var thick1 = 3 if col % 5 == 0 else 1
			var thick2 = 3 if row % 5 == 0 else 1
			var error = game.get_point_error(Vector2(x, y))
			draw_line(Vector2(x, y), Vector2(x + 20, y), Color.BLACK, thick1, false)
			draw_line(Vector2(x, y), Vector2(x, y + 20), Color.BLACK, thick2, false)
			#var rect = Rect2(Vector2(x, y), Vector2(4, 4))
			#var color = {
				#GameConst.ERROR.IS_AVAILABLE: Color.RED,
				#GameConst.ERROR.IS_INSIDE_TABLE: Color.BLUE,
				#GameConst.ERROR.IS_INSIDE_KITCHEN: Color.PURPLE,
				#GameConst.ERROR.IS_INSIDE_WALL: Color.YELLOW,
				#GameConst.ERROR.IS_OUTSIDE_MAP: Color.WHITE
			#}[error]
			#draw_rect(rect, color, true, 1.0)

func _ready():
	pass
	
func init(t_game):
	game = t_game
	queue_redraw()
