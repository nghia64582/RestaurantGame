extends Object
class_name GameUtils

static func log(st):
	print(st)
	
static func float_modulo(float_value, int_value):
	return float_value - int(float_value / int_value) * int_value

static func convert_point_to_hash(point: Vector2):
	return int(int(point.x) * 10000 + int(point.y) * 1)
	
static func convert_hash_to_point(hash: int) -> Vector2:
	return Vector2(hash / 10000, hash % 10000)

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

static func distance_point_to_line(point: Vector2, line_start: Vector2, line_end: Vector2) -> float:
	var line_vec = line_end - line_start
	var point_vec = point - line_start
	var line_len = line_vec.length()
	if line_len == 0:
		return point_vec.length()
	var line_unit_vec = line_vec / line_len
	var projection_length = point_vec.dot(line_unit_vec)
	if projection_length < 0:
		return point_vec.length()
	elif projection_length > line_len:
		return (point - line_end).length()
	var projection_vec = line_unit_vec * projection_length
	var closest_point = line_start + projection_vec
	return (point - closest_point).length()
	
static func is_obtascle(start: Vector2, target: Vector2, object: Vector2, radius: float) -> bool:
	var b1 = abs((object - start).angle_to(target - start)) < PI / 4
	var b2 = abs((object - target).angle_to(start - target)) < PI / 4
	var close_to_line = distance_point_to_line(object, start, target) <= 2 * radius
	return b1 and b2 and close_to_line
	
static func get_side_targets(start: Vector2, obstacle: Vector2, radius: float):
	var dist = start.distance_to(obstacle)
	var d_angle = acos(2 * radius / dist)
	var base_reverse = start - obstacle
	var a1 = base_reverse.rotated(d_angle)
	var a2 = base_reverse.rotated(-d_angle)
	var d1 = obstacle + a1.normalized() * 2 * radius
	var d2 = obstacle + a2.normalized() * 2 * radius
	return [d1, d2]
