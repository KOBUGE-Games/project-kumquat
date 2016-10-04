extends TextureFrame

func _ready():
	viewport_resized()
	get_viewport().connect("size_changed", self, "viewport_resized")

func viewport_resized():
	set_size(get_viewport_rect().size)
