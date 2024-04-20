extends Object
class_name Order

var guest
var table
var foods_id = []
var waiter
var kitchen
var state

func _ready():
	state = OrderConst.STATE.NOT_ORDERED
	kitchen = null
