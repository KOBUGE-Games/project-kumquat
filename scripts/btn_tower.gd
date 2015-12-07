extends Button

var tower_desc
var budget_current
export var tower_name = "Unnamed"
export var tower_damage = 100
export var tower_range = 100
export var tower_reload = 1
export var tower_price = 100

func _ready():
	budget_current = get_node("/root/game/hud").budget_current
	tower_desc = get_node("/root/game/hud/tower_desc")
	print(budget_current)
	if budget_current < tower_price:
		set_disabled(true)

func _on_btnTower_mouse_enter():
	tower_desc.set_pos(Vector2(get_pos().x+get_size().x+10,get_parent().get_pos().y+get_pos().y))
	get_node("/root/game/hud/tower_desc/panel/tower_name").set_text(tower_name)
	get_node("/root/game/hud/tower_desc/panel/tower_damage").set_text("Damage: "+str(tower_damage))
	get_node("/root/game/hud/tower_desc/panel/tower_range").set_text("Range: "+str(tower_range))
	get_node("/root/game/hud/tower_desc/panel/tower_reload").set_text("Reload: "+str(tower_reload))
	get_node("/root/game/hud/tower_desc/panel/tower_price").set_text("Price: "+str(tower_price))
	tower_desc.show()

func _on_btnTower_mouse_exit():
	tower_desc.hide()

func _on_btnTower_pressed():
	budget_current = get_node("/root/game/hud").budget_current
	if budget_current >= tower_price:
		get_node("/root/game/hud").updateBudget(-tower_price)
		get_node("/root/game/hud").placeTower = true
		get_node("/root/game/hud/cursor_placeholder").show()
