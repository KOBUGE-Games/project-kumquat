
extends Timer

export(PackedScene) var scene
export(int) var spawn_amount
var amount_left
export(bool) var override_timer_wait_time = true
export(IntArray) var starts
var starts_dict = {}

func _ready():
	if starts == null || starts.size() == 0:
		starts = range(get_parent().starts_open.size())
	for start in starts:
		starts_dict[start] = true
	
	if override_timer_wait_time:
		set_wait_time(get_parent().total_time / spawn_amount)
