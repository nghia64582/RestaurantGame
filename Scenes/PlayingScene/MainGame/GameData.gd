extends Object
class_name GameData

var cash: int
var exp: int
var level: int
var gem: int
var kitchen_pos: Array
var tables: Array
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
	
func load_data():
	var data = GameUtils.load_game()
	print("Data1 : ", data)
	if data == {}:
		data = get_base_config()
	print("Data2 : ", data)
	cash = data["cash"]
	exp = data["exp"]
	level = data["level"]
	gem = data["gem"]
	kitchen_pos = data["kitchen_pos"]
	tables = data["tables"]
	n_waiter = data["n_waiter"]
	n_width = data["n_width"]
	n_height = data["n_height"]

func get_base_config():
	return GameUtils.get_dict_from_file("BaseConfig.json")

func set_game(t_game: MainGame):
	game = t_game
	
func finished_guest_order(order: Order):
	exp += 1
	cash += len(order.foods_id)
	game.update_ui_game_data()
