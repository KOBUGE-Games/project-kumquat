extends Node2D

### Classes ###

class Tile:
	const TILE_SOLID = 0
	const TILE_WALKABLE = 1
	const TILE_BUILDABLE = 2
	
	var type = TILE_WALKABLE
	var possible_directions = []
	var goal_directions = []
	var tower = null

### Variables ###

# Consts
const DIRECTIONS = Vector2Array([Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)])

# Nodes and resources
var tilemap

export var cell_size = Vector2(32, 32)
export var debug = false
var current_wave_index = 1
var current_wave

var tiles = {}

var goals = []
var starts = []

# Dictionary containing tile types. They are formed by taking the first part of the tilename.
var tile_types = {
	"grass": Tile.TILE_WALKABLE,
	"dirt": Tile.TILE_WALKABLE,
	
	"tower": Tile.TILE_BUILDABLE,
	"wall": Tile.TILE_SOLID
}

### Callbacks ###

func _enter_tree():
	tilemap = get_node("tilemap")
	
	tiles = {}
	import_tilemap(tilemap, Tile.TILE_WALKABLE)

func _ready():
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
		var cell_name_first_part = cell_name.left(cell_name.find("_"))
		if tile_types.has(cell_name_first_part):
			new_tile.type = tile_types[cell_name_first_part]
		elif tile_types.has(cell_name):
			new_tile.type = tile_types[cell_name]
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
	if current_wave:
		for enemy in current_wave.enemies:
			enemy.disconnect("timeout", self, "spawn_enemy")
			enemy.stop()
			
	
	var node_path = str("waves/wave_", current_wave_index)
	if !has_node(node_path):
		print("WARN: No more waves @(",current_wave_index,")")
		return
	current_wave = get_node(str("waves/wave_", current_wave_index))
	
	if current_wave:
		for enemy in current_wave.enemies:
			enemy.connect("timeout", self, "spawn_enemy", [enemy])
			enemy.start()
			enemy.amount_left = enemy.spawn_amount
	
	for start_node in get_node("starts").get_children():
		start_node.hide()
	for start_node in current_wave.starts_open:
		start_node.show()
	
	current_wave_index += 1

func spawn_enemy(wave_enemy):
	var starts_avilable = []
	for i in range(current_wave.starts_open_positions.size()):
		if wave_enemy.starts_dict.has(i):
			starts_avilable.push_back((current_wave.starts_open_positions[i]/cell_size).floor())
	var start = starts_avilable[randi() % starts_avilable.size()]
	var position = start*cell_size + cell_size/2
	
	if wave_enemy.amount_left == 0:
		wave_enemy.stop()
	else:
		wave_enemy.amount_left -= 1
	
		var enemy = wave_enemy.scene.instance()
		enemy.set_pos(position)
		add_child(enemy)
