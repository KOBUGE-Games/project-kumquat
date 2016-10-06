extends CanvasLayer

### Variables ###

# Nodes
var global
var level
var budget
var healthbar
var tween

export var budget_current = 1000
export var health_current = 1000
export(PackedScene) var lose_scene
export(PackedScene) var win_scene

onready var health_max = health_current

var tower_placement = false
var carried_tower = null

var damage_per_last_second = 0
var damage_per_second = 0
var damage_total = 0
var second_left = 0
var game_ended = false

### Callbacks ###

func _enter_tree():
	get_node("/root/global").hud = self

func _ready():
	global = get_node("/root/global")
	level = global.level
	budget = get_node("top_bar/container/stats/budget/label")
	healthbar = get_node("top_bar/container/healthbar")
	tween = get_node("tween")
	
	if level != null:
		connect_level()
	
	update_budget_text()
	update_health(0)
	
	set_process_input(true)
	set_fixed_process(true)

func _fixed_process(delta):
	second_left -= delta
	if second_left < 0:
		second_left += 1
		damage_per_last_second = damage_per_second
		damage_per_second = 0
		add_damage(0)

func _input(ev):
	if level == null:
		level = global.level
		if level != null:
			connect_level()
		return
	ev = level.make_input_local(ev)
	if tower_placement and carried_tower:
		if ev.type == InputEvent.MOUSE_MOTION:
			var tile_pos = level.tilemap.world_to_map(ev.pos - level.get_global_pos())
			carried_tower.set_pos(level.tilemap.map_to_world(tile_pos) + global.TILE_OFFSET + Vector2(0,-8))
			
			update_budget_text()
		
		elif ev.type == InputEvent.MOUSE_BUTTON and ev.is_pressed() and !ev.is_echo():
			if ev.button_index == BUTTON_LEFT:
				# Place an instance of the carried tower
				var tile_pos = level.tilemap.world_to_map(ev.pos - level.get_global_pos())
				if level.tiles.has(tile_pos) and carried_tower.can_place(level.tiles[tile_pos].type, level.tiles[tile_pos].tower) \
						and budget_current - carried_tower.get_price(tile_pos) >= 0:
					# Place the carried tower
					update_budget(-carried_tower.get_price(tile_pos))
					var placed_tower = carried_tower.duplicate()
					# Apparently state is lost upon duplicate...
					placed_tower.current_tier = carried_tower.current_tier
					level.add_child(placed_tower)
					placed_tower.set_carried(false)
			elif ev.button_index == BUTTON_RIGHT:
				# Cancel the pending placement and discard the carried tower
				cancel_tower_placement()

### Functions

func connect_level():
	var next_wave_button = get_node("side_actions/next_wave")
	next_wave_button.connect("pressed", level, "next_wave")
	level.connect("wave_started", next_wave_button, "hide")
	level.connect("wave_finished", self, "show_next_wave", [level])

func add_damage(amount):
	damage_total += amount
	damage_per_second += amount
	var text = str("Damage: ", damage_total, " Total / ", damage_per_last_second, " Per second")
	get_node("top_bar/container/stats/damage/label").set_text(text)

func update_budget(amount):
	budget_current += amount
	update_budget_text()

func update_budget_text():
	if tower_placement and carried_tower:
		var tile_pos = level.tilemap.world_to_map(carried_tower.get_pos() - global.TILE_OFFSET - Vector2(0,-8))
		if level.tiles.has(tile_pos):
			carried_tower.update_status(level.tiles[tile_pos].type, level.tiles[tile_pos].tower, budget_current)
			var price = carried_tower.get_price(tile_pos)
			budget.set_text(str("Budget: ", budget_current, " - ", price))
			if price > budget_current:
				budget.get_node("../animation_player").play("no_money")
		else:
			carried_tower.update_status(level.Tile.TILE_SOLID, null, budget_current)
			budget.set_text(str("Budget: ", budget_current))
	else:
		budget.set_text(str("Budget: ", budget_current))

func update_health(amount):
	health_current += amount
	healthbar.get_node("fill").set_margin(MARGIN_RIGHT, float(health_current)/health_max)
	healthbar.get_node("label").set_text("Health: " + str(health_current))
	
	if health_current <= 0:
		end_game(false)

func cancel_tower_placement():
	tower_placement = false
	update_budget(0)
	carried_tower.queue_free()

func end_game(win):
	if game_ended:
		return
	game_ended = true
	if win:
		add_child(win_scene.instance())
	else:
		add_child(lose_scene.instance())

### Signals ###

func tower_build_mode(tower_scene, tower_tier):
	if tower_placement and carried_tower:
		carried_tower.queue_free()
	
	tower_placement = true
	carried_tower = tower_scene.instance()
	carried_tower.current_tier = tower_tier
	level.add_child(carried_tower)
	carried_tower.set_pos(Vector2(48, 48))
	carried_tower.set_carried(true)

func tower_upgrade_mode(upgrade_scene):
	if tower_placement and carried_tower:
		carried_tower.queue_free()
	
	tower_placement = true
	carried_tower = upgrade_scene.instance()
	level.add_child(carried_tower)
	carried_tower.set_pos(Vector2(48, 48))
	carried_tower.set_carried(true)

func show_next_wave(level):
	if !level.is_last_wave():
		var next_wave_button = get_node("side_actions/next_wave")
		next_wave_button.show()
