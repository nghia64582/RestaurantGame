extends Object
class_name IdGenerator

static var guest_id_counter = 0
static var waiter_id_counter = 0
static var table_id_counter = 0
static var kitchen_id_counter = 0

static func get_guest_id():
	guest_id_counter += 1
	return guest_id_counter
	
static func get_waiter_id():
	waiter_id_counter += 1
	return waiter_id_counter
	
static func get_table_id():
	table_id_counter += 1
	return table_id_counter
	
static func get_kitchen_id():
	kitchen_id_counter += 1
	return kitchen_id_counter
