extends Control

var level_box = preload("res://menu/level_box.tscn")
var total_levels = 12 #TODO get the number of levels
var pages = total_levels / 3
var current_page = 0

var selected_level = -1
var allow_navigation = true

func _ready():
	var level_counter = 0
	var level_spacing = 0
	
	for i in range(total_levels):
		if level_counter == 3:
			level_spacing += 150
			level_counter = 0
		level_counter += 1
		var new_level_box = level_box.instance()
		new_level_box.set_pos(Vector2(i*325+level_spacing,0))
		new_level_box.level = level_counter
		get_node("levels").add_child(new_level_box)
	
	toggle_navigation()
	

func toggle_navigation():
	if current_page == 0:
		get_node("navigation/menu_left").hide()
	else:
		get_node("navigation/menu_left").show()
		
	if current_page == pages-1:
		get_node("navigation/menu_right").hide()
	else:
		get_node("navigation/menu_right").show()

func _on_menu_right_pressed():
	if current_page < pages-1 and allow_navigation:
		allow_navigation = false
		get_node("levels/tween").stop(get_node("levels"), "rect/pos")
		get_node("levels/tween").interpolate_property(get_node("levels"), "rect/pos", get_node("levels").get_pos(), get_node("levels").get_pos() - Vector2(975+150,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		get_node("levels/tween").start()
		current_page += 1
		toggle_navigation()

func _on_menu_left_pressed():
	if current_page > 0 and allow_navigation:
		allow_navigation = false
		get_node("levels/tween").stop(get_node("levels"), "rect/pos")
		get_node("levels/tween").interpolate_property(get_node("levels"), "rect/pos", get_node("levels").get_pos(), get_node("levels").get_pos() + Vector2(975+150,0), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
		get_node("levels/tween").start()
		current_page -= 1
		toggle_navigation()

func _on_tween_tween_complete( object, key ):
	allow_navigation = true

func _on_play_pressed():
	if selected_level != -1:
		get_node("/root/global").go_to_level(selected_level)
