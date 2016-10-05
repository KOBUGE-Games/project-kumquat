extends ParallaxBackground

onready var viewport = get_parent().get_viewport()
onready var texture = get_node("layer/texture")

func _ready():
	update_values()
	viewport.connect("size_changed", self, "update_values")

func update_values():
	texture.set_size(viewport.get_rect().size / viewport.get_canvas_transform().get_scale())
	set_scroll_base_scale(viewport.get_canvas_transform().get_scale())
