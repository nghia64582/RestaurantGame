extends Object
class_name GameUtils

static func log(st):
	print(st)
	
static func float_modulo(float_value, int_value):
	return float_value - int(float_value / int_value) * int_value

static func get_hash(point: Vector2):
	return int(point.x * 321 + point.y * 123)

static func is_middle_straight(point: Vector2, p1: Vector2, p2: Vector2):
	if point.x == p1.x and point.x == p2.x and \
		(point.y - p1.y) * (point.y - p2.y) < 0:
		return true
	if point.y == p1.y and point.y == p2.y and \
		(point.x - p1.x) * (point.x - p2.x) < 0:
		return true
	return false
