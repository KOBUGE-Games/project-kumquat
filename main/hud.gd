extends CanvasLayer

### Variables ###

# Nodes
var global
var level
var budget
var health

export var budget_current = 1000
export var health_current = 1000

var tower_placement = false
var carried_tower = null

var damage_per_last_second = 0
var damage_per_second = 0
var damage_total = 0
var second_left = 0

### Callbacks ###

func _enter_tree():
	get_node("/root/global").hud = self

func _ready():
	global = get_node("/root/global")
	level = global.level
	budget = get_node("stats/budget/label")
	health = get_node("stats/health/label")
	
	get_node("next_wave").connect("pressed", level, "next_wave")
	
	budget.set_text("Budget: " + str(budget_current))
	health.set_text("Health: " + str(health_current))
	
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

func add_damage(amount):
	damage_total += amount
	damage_per_second += amount
	get_node("stats/damage/label").set_text(str("Damage:\n  Total: ", damage_total, "\n  Per second: ", damage_per_last_second))

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
	health.set_text("Health: " + str(health_current))

func cancel_tower_placement():
	tower_placement = false
	update_budget(0)
	carried_tower.queue_free()

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
