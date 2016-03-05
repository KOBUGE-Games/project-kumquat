extends Control

export var camera_speed = 500
export var camera_offset = 0

onready var camera = get_node("level_control/camera")

### Callbacks ###

func _enter_tree():
	get_node("/root/global").game = self

func _ready():
	randomize()
	
	var size = get_node("level_control").get_size()
	camera.set_pos(size/2)
	# Camera has a weird bug: https://github.com/godotengine/godot/issues/1912
	size /= camera.get_zoom()
	camera.set_limit(MARGIN_TOP, -camera_offset)
	camera.set_limit(MARGIN_LEFT, -camera_offset)
	camera.set_limit(MARGIN_BOTTOM, size.height + camera_offset)
	camera.set_limit(MARGIN_RIGHT, size.width + camera_offset)
	
	var level = get_node("/root/global").level_to_load
	var level_scene = load(str("res://levels/level", level, ".tscn"))
	get_node("level_control").add_child(level_scene.instance())
	
	set_fixed_process(true)

func _fixed_process(delta):
	var camera_move = Vector2(0, 0)
	
	if Input.is_action_pressed("ui_up"):
		camera_move += Vector2(0, -1)
	if Input.is_action_pressed("ui_down"):
		camera_move += Vector2(0, 1)
	if Input.is_action_pressed("ui_left"):
		camera_move += Vector2(-1, 0)
	if Input.is_action_pressed("ui_right"):
		camera_move += Vector2(1, 0)
	
	if camera_move.length_squared() > 0.1:
		var current_pos = camera.get_camera_screen_center()
		camera.set_pos(current_pos + camera_move*delta*camera_speed)