
extends ReferenceFrame

export var move_to_target = false
export var hide_when_inactive = false
export var debounce_time = 0.5

var tooltip
var animation_player
var timer

var label_formats = StringArray()
var next_animation = ""

func _ready():
	tooltip = get_node("tooltip")
	animation_player = get_node("animation_player")
	timer = get_node("timer")
	
	timer.connect("timeout", self, "play_next_animation")
	
	for label in tooltip.get_node("data").get_children():
		if label extends Label:
			label_formats.push_back(label.get_text())
	
	if hide_when_inactive:
		tooltip.hide()
	else:
		show()
		for label in tooltip.get_node("data").get_children():
			if label extends Label:
				label.hide()

func show_data(target, data):
	if move_to_target:
		set_pos(target.get_global_pos())
	
	if hide_when_inactive:
		next_animation = "enter"
		play_next_animation()
		timer.stop()
	
	var labels_passed = 0
	for label in tooltip.get_node("data").get_children():
		if label extends Label:
			if data.has(label.get_name()):
				label.show()
				var format = label_formats[labels_passed]
				var value = str(data[label.get_name()])
				label.set_text(format.replace("%s", value))
			else:
				label.hide()
			labels_passed += 1

func hide_data():
	if hide_when_inactive:
		next_animation = "exit"
		timer.set_wait_time(debounce_time)
		timer.start()


func play_next_animation():
	if animation_player.get_current_animation() != next_animation:
		animation_player.play(next_animation)