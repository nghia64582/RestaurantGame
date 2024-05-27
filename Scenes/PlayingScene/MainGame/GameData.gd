extends Object
class_name GameData

var cash: int
var exp: int
var level: int
var gem: int

var game: MainGame

func init(t_game: MainGame):
	game = t_game
	cash = 30
	exp = 0
	level = 1
	gem = 100
	
func finished_guest_order(order: Order):
	exp += 1
	cash += len(order.foods_id)
	game.update_ui_game_data()
