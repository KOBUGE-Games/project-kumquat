extends Button

### Variables ###

# Nodes
var global
var hud # The HUD node
var tooltip # The tower tooltip

# Characteristics
export(PackedScene) var tower_scene
export(int, 1, 3) var tower_tier = 1
export var unlocked = false
var tower_name = "Unnamed"
var tower_damage = 100
var tower_range = 100
var tower_price = 100
var tower_reload = 1
var unlock_price = 100

### Callbacks ###

func _ready():
	global = get_node("/root/global")
	hud = global.hud
	tooltip = hud.get_node("tower_tooltip")

	set_attributes_from_tower_scene(tower_scene)
	set_unlocked(unlocked)

func _fixed_process(delta):
	if hud.budget_current >= unlock_price:
		set_disabled(false)
		get_node("upgrade").set_hidden(false)
	else:
		set_disabled(true)
		get_node("upgrade").set_hidden(true)

### Functions ###

func set_attributes_from_tower_scene(tower_scene):
	var tower = tower_scene.instance() # TODO: Use SceneData API
	get_node("icon").set_texture(tower.get_node("sprite").get_texture())
	get_node("icon").set_frame(tower_tier - 1)
	
	var tier = tower.get_tier(tower_tier)
	tower_name = tier.name
	tower_damage = tier.damage
	tower_range = tier.reach
	tower_reload = tier.frequency
	tower_price = tier.price
	unlock_price = tier.unlock_price

func set_unlocked(enable):
	# If locked, check the budget continuously to see if it can be unlocked
	set_fixed_process(!enable)
	unlocked = enable
	set_disabled(!enable)
	get_node("icon").set_opacity(1.0 - int(!enable)*0.7)
	get_node("upgrade").set_hidden(enable)

### Signals ###

func _on_btn_tower_mouse_enter():
	get_node("upgrade").set_frame(15)
	var data = {
		name= tower_name,
		damage = tower_damage,
		reach = tower_range,
		reload = tower_reload
	}
	if unlocked:
		data.price = tower_price
	else:
		data.unlock = unlock_price
	tooltip.show_data(self, data)

func _on_btn_tower_mouse_exit():
	get_node("upgrade").set_frame(14)
	tooltip.hide_data()

func _on_btn_tower_pressed():
	if unlocked:
		hud.tower_build_mode(tower_scene, tower_tier)
	else:
		hud.update_budget(-unlock_price)
		set_unlocked(true)
