extends Object
class_name FoodHelper

static func get_random_foods():
	var result = []
	var n_foods = randi_range(1, randi_range(1, 3))
	for idx in range(n_foods):
		result.append(randi_range(FoodConst.TYPE.HAMBURGER, FoodConst.TYPE.SOUP))
	return result

