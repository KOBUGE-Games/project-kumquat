extends Node2D

### Classes ###

class Tile:
	const TILE_SOLID = 0
	const TILE_WALKABLE = 1
	const TILE_BUILDABLE = 2
	
	var type = TILE_WALKABLE
	var possible_directions = []
	var goal_directions = []
	var has_tower = false

class Wave:
	var enemies = []
	var spawn_cooldown = 1
	func _init(_enemies, _spawn_cooldown = 1):
		enemies = _enemies
		spawn_cooldown = _spawn_cooldown

class WaveEnemy:
	var scene
	var count = 1 # Should it be frequency instead?
	func _init(_scene, _count = 1):
		scene = _scene
		count = _count

### Variables ###

# Consts
const DIRECTIONS = Vector2Array([Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)])

# Nodes and resources
var enemy1_scene = preload("res://scenes/enemies/enemy1.tscn")
var tilemap_walkable
var tilemap_buildable

export var cell_size = Vector2(32, 32)
export var debug = false

var waves = [
	Wave.new([
		WaveEnemy.new(enemy1_scene, 10)
	]),
	Wave.new([
		WaveEnemy.new(enemy1_scene, 20)
	], 1.2),
	Wave.new([
		WaveEnemy.new(enemy1_scene, 30)
	], 1.2)
]
var current_wave_index = 0
var current_wave

var tiles = {}

var goals = []
var starts = []

var tile_type_override = {
	"wall_s": Tile.TILE_SOLID,
	"wall_e": Tile.TILE_SOLID,
	"wall_w": Tile.TILE_SOLID,
	"wall_overlap_e": Tile.TILE_SOLID,
	"wall_overlap_s": Tile.TILE_SOLID
}

### Callbacks ###

func _enter_tree():
	tilemap_walkable = get_node("tilemap_grass")
	tilemap_buildable = get_node("tilemap_tower")
	
	tiles = {}
	import_tilemap(tilemap_walkable, Tile.TILE_WALKABLE)
	import_tilemap(tilemap_buildable, Tile.TILE_BUILDABLE)

func _ready():
	get_node("enemy_timer").connect("timeout", self, "spawn_enemy")
	
	update_endpoints()
	update_tile_directions()
	run_bfs()
	update()
	next_wave()

func _draw():
	if not debug:
		return
	# Debug overlay
	var colors = [Color(0, 0, 0, 0.5), Color(0, 0, 1, 0.3), Color(1, 0, 0, 0.3)]
	for cell in tiles:
		var tile = tiles[cell]
		
		draw_rect(Rect2(cell*cell_size, cell_size), colors[tile.type])
		
		for direction in tile.possible_directions:
			draw_rect(Rect2(cell*cell_size + cell_size/8*3 + cell_size*direction/3, cell_size/4), Color(1, 1, 1, 0.5))
		
		for direction in tile.goal_directions:
			draw_rect(Rect2(cell*cell_size + cell_size/8*3 + cell_size*direction/4, cell_size/4), Color(1, 0, 1, 0.5))
	
	for goal in goals:
		draw_rect(Rect2(goal*cell_size, cell_size), Color(1, 1, 0, 0.6))
	
	for start in starts:
		draw_rect(Rect2(start*cell_size, cell_size), Color(0, 1, 1, 0.6))

### Functions ###

func import_tilemap(tilemap, default_tile_type):
	var tileset = tilemap.get_tileset()
	for cell in tilemap.get_used_cells():
		var new_tile = Tile.new()
		var cell_type = tilemap.get_cell(cell.x, cell.y)
		var cell_name = tileset.tile_get_name(cell_type)
		if tile_type_override.has(cell_name):
			new_tile.type = tile_type_override[cell_name]
		else:
			new_tile.type = default_tile_type
		
		tiles[cell] = new_tile

func update_endpoints():
	for goal_node in get_node("goals").get_children():
		goals.push_back((goal_node.get_pos()/cell_size).floor())
	
	for start_node in get_node("starts").get_children():
		starts.push_back((start_node.get_pos()/cell_size).floor())

func update_tile_directions():
	for cell in tiles:
		var tile = tiles[cell]
		
		if tile.type == Tile.TILE_WALKABLE:
			for direction in DIRECTIONS:
				var direction_cell = cell + direction
				if tiles.has(direction_cell) and tiles[direction_cell].type == Tile.TILE_WALKABLE:
					tile.possible_directions.push_back(direction)

func run_bfs():
	var scanline = goals
	var passed = {}
	var distance = {}
	for goal in goals:
		distance[goal] = 0
	
	while scanline.size() > 0:
		var new_scanline = []
		for cell in scanline:
			
			for direction in tiles[cell].possible_directions:
				var other_cell = cell + direction
				if not passed.has(other_cell) and tiles.has(other_cell):
					passed[other_cell] = true
					distance[other_cell] = distance[cell] + 1
					
					new_scanline.push_back(other_cell)
		scanline = new_scanline
	
	for cell in passed:
		var tile = tiles[cell]
		for direction in tile.possible_directions:
			var other_cell = cell + direction
			if distance[cell] > distance[other_cell]:
				tile.goal_directions.push_back(direction)

func next_wave():
	if current_wave_index >= waves.size():
		print("ERROR: current_wave_index out of size.")
		return
	current_wave = waves[current_wave_index]
	get_node("enemy_timer").set_wait_time(current_wave.spawn_cooldown)
	get_node("enemy_timer").start()
	
	current_wave_index += 1

func spawn_enemy():
	var start = starts[randi() % starts.size()]
	var position = start*cell_size + cell_size/2
	
	var total_count = 0
	
	for wave_enemy in current_wave.enemies:
		total_count += wave_enemy.count
	
	if total_count == 0:
		get_node("enemy_timer").stop()
		return
	
	var enemy_id = randi() % total_count
	
	for wave_enemy in current_wave.enemies:
		enemy_id -= wave_enemy.count
		if enemy_id <= 0:
			wave_enemy.count -= 1
			
			var enemy = wave_enemy.scene.instance()
			enemy.set_pos(position)
			add_child(enemy)
			break
