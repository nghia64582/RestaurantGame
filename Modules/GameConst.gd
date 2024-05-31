extends Object
class_name GameConst

const DIRECT = {
	NONE = -1,
	UP = 0,
	RIGHT = 1,
	DOWN = 2,
	LEFT = 3
}

const DIRECT_COOR = [
	Vector2(0, -1),
	Vector2(1, 0),
	Vector2(0, 1),
	Vector2(-1, 0)
]

const ERROR = {
	IS_AVAILABLE = 0,
	IS_INSIDE_TABLE = 1,
	IS_INSIDE_KITCHEN = 2,
	IS_INSIDE_WALL = 3,
	IS_OUTSIDE_MAP = 4
}
