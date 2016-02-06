
extends Control

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Initialization here
	pass

func _on_menu_right_pressed():
	print("A")
	get_node("levels/tween").stop(get_node("levels"), "rect/pos")
	get_node("levels/tween").interpolate_property(get_node("levels"), "rect/pos", Vector2(0,0), Vector2(300,300), 5, Tween.TRANS_LINEAR, Tween.EASE_IN)
	get_node("levels/tween").start()
