
extends Node2D

class Tile:
	const TILE_SOLID = 0
	const TILE_WALKABLE = 1
	const TILE_BUILDABLE = 2
	
	var type = TILE_WALKABLE
	var possible_directions = []
	var goal_directions = []

const DIRECTIONS = Vector2Array([Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)])

export var cell_size = Vector2(32,32)
export var debug = true

var tiles = {}
var tilemap_walkable
var tilemap_buildable

var goals = []
var starts = []

var tile_type_override = {
	"wall_s": Tile.TILE_SOLID,
	"wall_e": Tile.TILE_SOLID,
	"wall_w": Tile.TILE_SOLID
}

func _ready():
	tilemap_walkable = get_node("tilemap_grass")
	tilemap_buildable = get_node("tilemap_tower")
	
	update_endpoints()
	update_tiles()
	update()

func update_tiles():
	tiles = {}
	import_tilemap(tilemap_walkable, Tile.TILE_WALKABLE)
	import_tilemap(tilemap_buildable, Tile.TILE_BUILDABLE)
	
	for cell in tiles:
		var tile = tiles[cell]
		
		if tile.type == Tile.TILE_WALKABLE:
			for direction in DIRECTIONS:
				var direction_cell = cell + direction
				if tiles.has(direction_cell) and tiles[direction_cell].type == Tile.TILE_WALKABLE:
					tile.possible_directions.push_back(direction)
	
	var scanline = goals
	var passed = {}
	print(goals.size())
	while scanline.size() > 0:
		var new_scanline = []
		for cell in scanline:
			
			for direction in tiles[cell].possible_directions:
				var other_cell = cell + direction
				if not passed.has(other_cell) and tiles.has(other_cell):
					passed[other_cell] = true
					
					tiles[other_cell].goal_directions.push_back(-direction)
					
					new_scanline.push_back(other_cell)
			
		scanline = new_scanline

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
		goals.push_back((goal_node.get_pos() / cell_size).floor())
	
	for start_node in get_node("starts").get_children():
		starts.push_back((start_node.get_pos() / cell_size).floor())

func _draw():
	if not debug:
		return
	# Debug overlay
	var cell_size = tilemap_buildable.get_cell_size()
	var colors = [Color(0,0,0, 0.5),Color(0,0,1, 0.3),Color(1,0,0, 0.3)]
	for cell in tiles:
		var tile = tiles[cell]
		
		draw_rect( Rect2(cell*cell_size , cell_size), colors[tile.type])
		
		for direction in tile.possible_directions:
			draw_rect( Rect2(cell*cell_size + cell_size/8*3 + cell_size * direction / 3, cell_size/4), Color(1,1,1, 0.5))
		
		for direction in tile.goal_directions:
			draw_rect( Rect2(cell*cell_size + cell_size/8*3 + cell_size * direction / 4, cell_size/4), Color(1,0,1, 0.5))
	
	for goal in goals:
		draw_rect( Rect2(goal*cell_size , cell_size), Color(1,1,0, 0.6))
	
	for start in starts:
		draw_rect( Rect2(start*cell_size , cell_size), Color(0,1,1, 0.6))
