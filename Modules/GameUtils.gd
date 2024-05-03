extends Object
class_name GameUtils

static func log(st):
	print(st)
	
static func float_modulo(float_value, int_value):
	return float_value - int(float_value / int_value) * int_value
