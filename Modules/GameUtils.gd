extends Object
class_name GameUtils

static func log(st):
	print(st)
	
static func float_modulo(float_value, int_value):
	return float_value - int(float_value / int_value) * int_value

static func convert_point_to_hash(point: Vector2):
	return int(int(point.x) * 1000 + int(point.y) * 1)
	
static func convert_hash_to_point(hash: int) -> Vector2:
	return Vector2(hash / 1000, hash % 1000)

static func is_middle_straight(point: Vector2, p1: Vector2, p2: Vector2):
	if point.x == p1.x and point.x == p2.x and \
		(point.y - p1.y) * (point.y - p2.y) < 0:
		return true
	if point.y == p1.y and point.y == p2.y and \
		(point.x - p1.x) * (point.x - p2.x) < 0:
		return true
	return false

static func convert_time_format(hours: int, minutes: int) -> String:
	var marker = "AM" if hours <= 11 else "PM"
	hours %= 12
	var hours_st = "%02d" % hours
	var minutes_st = "%02d" % minutes
	return hours_st + ":" + minutes_st + " " + marker

static func get_random_directs(unit):
	var directs = [Vector2.RIGHT * unit, Vector2.DOWN * unit, Vector2.LEFT * \
		unit, Vector2.UP * unit]
	randomize()
	directs.shuffle()
	return directs

static func get_level(exp):
	for level_conf in GameConfig.level_config:
		if level_conf["min_exp"] <= exp and exp <= level_conf["max_exp"]:
			return level_conf["level"]
	return 1
	
static func get_cur_exp(exp):
	for level_conf in GameConfig.level_config:
		if level_conf["min_exp"] <= exp and exp <= level_conf["max_exp"]:
			return exp - level_conf["min_exp"]
	return 1

static func get_max_exp_by_level(level):
	for level_conf in GameConfig.level_config:
		if level == level_conf["level"]:
			return level_conf["max_exp"] - level_conf["min_exp"] + 1
	return 1000

static func get_level_text(exp):
	var level = get_level(exp)
	var cur_exp = get_cur_exp(exp)
	var max_exp = get_max_exp_by_level(level)
	return "Lv %d : %d/%d" % [level, cur_exp, max_exp]
	
static func get_json(file_path):
	var json_as_text = FileAccess.get_file_as_string(file_path)
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		return json_as_dict
	return null
