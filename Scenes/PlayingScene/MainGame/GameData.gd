extends Object
class_name GameData

var cash: int
var exp: int
var level: int
var gem: int
var kitchen_pos: Array[Dictionary]
var tables: Array[Dictionary]
var n_waiter: int
var n_width: int
var n_height: int

var game: MainGame

func get_dict():
	return {
		"cash": cash,
		"exp": exp,
		"level": level,
		"gem": gem,
		"kitchen_pos": kitchen_pos,
		"tables": tables,
		"n_waiter": n_waiter,
		"n_width": n_width,
		"n_height": n_height
	}

func init(t_game: MainGame):
	game = t_game
	cash = 30
	exp = 1
	level = 1
	gem = 100
	
func finished_guest_order(order: Order):
	exp += 1
	cash += len(order.foods_id)
	game.update_ui_game_data()
