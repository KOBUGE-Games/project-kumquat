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
	
	set_fixed_process(true)

func _fixed_process(delta):
	if Input.is_action_pressed("ui_up"):
		camera.translate(Vector2(0, -1)*delta*camera_speed)
	if Input.is_action_pressed("ui_down"):
		camera.translate(Vector2(0, 1)*delta*camera_speed)
	if Input.is_action_pressed("ui_left"):
		camera.translate(Vector2(-1, 0)*delta*camera_speed)
	if Input.is_action_pressed("ui_right"):
		camera.translate(Vector2(1, 0)*delta*camera_speed)
