extends Node2D
class_name GuestSpineFactory

@export var guest_spine_1: Spine
@export var guest_spine_2: Spine
@export var guest_spine_3: Spine
@export var guest_spine_4: Spine
@export var guest_spine_5: Spine
@export var guest_spine_6: Spine
@export var guest_spine_7: Spine
@export var guest_spine_8: Spine
@export var guest_spine_9: Spine
@export var guest_spine_10: Spine

func get_spine_by_id(id):
	var results = [guest_spine_1, guest_spine_2, guest_spine_3, guest_spine_4, guest_spine_5, \
		guest_spine_6, guest_spine_7, guest_spine_8, guest_spine_9, guest_spine_10]
	return results[id - 1]
