extends Node2D

var state
var sprite_idx
var count_down
var max_count_down
var game
var kitchen

@export var state_lb: Label
@export var image: Sprite2D
@export var progress_bar: ProgressBar
@export_group("Cooking images")
@export var cooking_images: Array[Texture2D] = []
@export_group("Wait for order 1 images")
@export var wait_for_order_1_images: Array[Texture2D] = []
@export_group("Wait for order 2 images")
@export var wait_for_order_2_images: Array[Texture2D] = []

func _ready():
	update_state(ChefConst.STATE.WAIT_FOR_ORDER)
	sprite_idx = -1
	count_down = 0

func _process(delta):
	queue_redraw()
	update_sprite()
	update_progress_bar()
	check_and_update_cooking(delta)

func update_progress_bar():
	if max_count_down == 0 or count_down <= 0.1:
		progress_bar.visible = false
	else:
		progress_bar.visible = true
		progress_bar.value = count_down / max_count_down * 100

func update_sprite():
	sprite_idx += 1
	var textures = get_textures_of_state()
	if sprite_idx / 1 >= len(textures):
		sprite_idx = 0
	image.texture = textures[sprite_idx / 1]

func get_textures_of_state():
	if state == ChefConst.STATE.COOKING:
		return cooking_images
	return wait_for_order_1_images

func check_and_update_cooking(delta):
	if state != ChefConst.STATE.COOKING:
		return
	count_down -= delta
	if count_down <= 0:
		print("Cooking countdown : " + str(count_down))
		update_state(ChefConst.STATE.FINISH_COOKING)

func start_cooking():
	if state != ChefConst.STATE.ORDERED:
		return
	update_state(ChefConst.STATE.COOKING)
	count_down = 3
	max_count_down = count_down

func check_change_state(new_state):
	if new_state == ChefConst.STATE.FINISH_COOKING:
		var waiter = kitchen.waiter
		waiter.update_state(WaiterConst.STATE.BRING_FOOD_TO_GUEST)
		var guest = waiter.guest
		var table = guest.order.table
		waiter.add_point(table.position)
		update_state(ChefConst.STATE.WAIT_FOR_ORDER)

func update_state(new_state):
	print("Chef change state to : " + ChefConst.STATE_NAME[new_state])
	state = new_state
	check_change_state(new_state)
	state_lb.text = ChefConst.STATE_NAME[state]
