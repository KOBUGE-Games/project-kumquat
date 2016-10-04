extends Node2D

export var camera_speed = 500
export var camera_offset = 0

onready var camera = get_node("level_holder/camera")

var level_instance

### Callbacks ###

func _enter_tree():
	get_node("/root/global").game = self

func _ready():
	randomize()
	
	var level = get_node("/root/global").level_to_load
	var level_scene = load(str("res://levels/level", level, ".tscn"))
	level_instance = level_scene.instance()
	get_node("level_holder").add_child(level_instance)
	
	viewport_resized()
	get_viewport().connect("size_changed", self, "viewport_resized")
	
	set_fixed_process(true)
	set_process_unhandled_input(true)

func _unhandled_input(event):
	event = make_input_local(event)
	if event.type == InputEvent.MOUSE_MOTION and event.button_mask & BUTTON_LEFT:
		var current_pos = camera.get_camera_screen_center()
		var camera_move = -event.relative_pos
		camera.set_pos(current_pos + camera_move)

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

func viewport_resized():
	var hud = get_node("hud")
	var rect = level_instance.get_tilemap_rect()
	var viewport_size = get_viewport_rect().size
	
	rect.pos -= viewport_size
	rect.size += viewport_size * 2
	
	camera.set_pos(rect.pos + rect.size/2)
	camera.set_limit(MARGIN_TOP, rect.pos.y - camera_offset)
	camera.set_limit(MARGIN_LEFT, rect.pos.x - camera_offset)
	camera.set_limit(MARGIN_BOTTOM, rect.size.height + rect.pos.y + camera_offset)
	camera.set_limit(MARGIN_RIGHT, rect.size.width + rect.pos.x + camera_offset)
