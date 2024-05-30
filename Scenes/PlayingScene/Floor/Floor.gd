extends Node2D


var game: MainGame
func _draw():
	if DevConfig.SHOW_GRID:
		for row in range(0, 50):
			for col in range(0, 50):
				var x = row * PathFinder.UNIT
				var y = col * PathFinder.UNIT
				var thick1 = 7 if col % 5 == 0 else 3
				var thick2 = 7 if row % 5 == 0 else 3
				var error = game.get_point_error(Vector2(x, y))
				draw_line(Vector2(x, y), Vector2(x + PathFinder.UNIT, y), Color.BLACK, thick1, false)
				draw_line(Vector2(x, y), Vector2(x, y + PathFinder.UNIT), Color.BLACK, thick2, false)
				var rect = Rect2(Vector2(x, y), Vector2(4, 4))
				var color = {
					GameConst.ERROR.IS_AVAILABLE: Color.RED,
					GameConst.ERROR.IS_INSIDE_TABLE: Color.BLUE,
					GameConst.ERROR.IS_INSIDE_KITCHEN: Color.PURPLE,
					GameConst.ERROR.IS_INSIDE_WALL: Color.YELLOW,
					GameConst.ERROR.IS_OUTSIDE_MAP: Color.WHITE
				}[error]
				draw_rect(rect, color, true, 5.0)

func _ready():
	pass
	
func init(t_game):
	game = t_game
	queue_redraw()
