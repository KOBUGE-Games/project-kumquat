extends TextureButton

var level = 1

func _ready():
	pass

func _on_level_box_pressed():
	for item in get_node("/root/menu/levels").get_children():
		if item.get_name() != "tween":
			item.get_node("selected").hide()
	get_node("/root/menu").selected_level = level
	get_node("selected").show()