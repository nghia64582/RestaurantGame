extends Label

@export var time_lb: Label

func _process(delta):
	update_time_lb()
	
func update_time_lb():
	var time_dict = Time.get_time_dict_from_system(false)
	var hour = time_dict["minute"] % 24
	var minute = time_dict["second"]
	var st = GameUtils.convert_time_format(hour, minute)
	time_lb.text = st
