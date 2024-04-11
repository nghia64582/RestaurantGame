extends Object
class_name Order

var guest_id
var table_id
var foods_id = []
var waiter_id
var kitchen_id
var state

func _ready():
	state = OrderConst.STATE.NOT_ORDERED
