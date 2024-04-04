extends Node

var state
var sprite_idx = 0
@export_group("Angry 1 images")
@export var angry_1_images: Array[Texture2D] = []
@export_group("Angry 2 images")
@export var angry_2_images: Array[Texture2D] = []
@export_group("Back view anim 1")
@export var back_view_1_images: Array[Texture2D] = []
@export_group("Back view anim 2")
@export var back_view_2_images: Array[Texture2D] = []
@export_group("Bored 1")
@export var bored_1_images: Array[Texture2D] = []
@export_group("Bored 2")
@export var bored_2_images: Array[Texture2D] = []
@export_group("Call waiter")
@export var call_waiter_images: Array[Texture2D] = []
@export_group("Drink")
@export var drink_images: Array[Texture2D] = []
@export_group("Eat")
@export var eat_images: Array[Texture2D] = []
@export_group("Read menu")
@export var read_menu_images: Array[Texture2D] = []
@export_group("Satisfied 1")
@export var satisfied_1_images: Array[Texture2D] = []
@export_group("Satisfied 2")
@export var satisfied_2_images: Array[Texture2D] = []
@export_group("Satisfied 3")
@export var satisfied_3_images: Array[Texture2D] = []
@export_group("Stand and angry")
@export var stand_and_angry_images: Array[Texture2D] = []
@export_group("Stand and bored")
@export var stand_and_bored_images: Array[Texture2D] = []
@export_group("Stand and wait")
@export var stand_and_wait_images: Array[Texture2D] = []
@export_group("Waiting for the food 1")
@export var waiting_for_food_1_images: Array[Texture2D] = []
@export_group("Waiting for the food 2")
@export var waiting_for_food_2_images: Array[Texture2D] = []
@export_group("Waiting for the food 3")
@export var waiting_for_food_3_images: Array[Texture2D] = []

func _ready():
	pass

func _process(delta):
	pass

func set_state(new_state):
	state = new_state
