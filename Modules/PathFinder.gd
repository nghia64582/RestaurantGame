extends Node
class_name PathFinder

static var distances = {}
static var game: MainGame
static var UNIT = 50

static func init(t_game: MainGame):
	print("Start initing path finder")
	var start = Time.get_ticks_msec()
	game = t_game
	for table in game.tables:
		init_point(table.position)
	for kitchen in game.kitchens:
		init_point(kitchen.waiter_pos)
	init_point(Vector2(300, 400))
	init_point(Vector2(500, 400))
	init_point(Vector2(700, 400))
	init_point(Vector2(100, 900))
	print("Time for path finder %d" % [Time.get_ticks_msec() - start])

static func init_point(start: Vector2):
	# Use BFS to find path to all available points in game
	var queue = [start]
	var distance = {GameUtils.convert_point_to_hash(start): 0}
	var directs = GameUtils.get_random_directs(UNIT)
	while not queue.is_empty():
		var cur_point = queue.pop_front()
		var head_hash = GameUtils.convert_point_to_hash(cur_point)
		for t_direct in directs:
			var next_point = Vector2(cur_point.x + t_direct.x, \
				cur_point.y + t_direct.y)
			var hash = GameUtils.convert_point_to_hash(next_point)
			var b1 = game.get_point_error(next_point) == GameConst.ERROR.IS_AVAILABLE
			var b2 = distance.get(hash, -1) == -1
			if b1 and b2:
				distance[hash] = distance[head_hash] + UNIT
				queue.push_back(next_point)
	distances[start] = distance

static func find_path(start: Vector2, target: Vector2):
	for point in distances.keys():
		if start.distance_to(point) < 1:
			var min_dist = 1e10
			var last_point = Vector2(0, 0)
			var distance = distances[point]
			for hash in distance.keys():
				var t_point = GameUtils.convert_hash_to_point(hash)
				var total_dist = distance[hash] + abs(t_point.x - target.x) + \
					abs(t_point.y - target.y)
				if total_dist < min_dist and t_point.distance_to(target) < UNIT * sqrt(2):
					min_dist = total_dist
					last_point = t_point
			return {
				"distance": distance,
				"last_point": last_point
			}
