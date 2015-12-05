
extends Node2D

class Tile:
	const TILE_SOLID = 0
	const TILE_WALKABLE = 1
	const TILE_BUILDABLE = 2
	
	var type = TILE_WALKABLE
	var possible_directions = []
	var goal_directions = []

const DIRECTIONS = Vector2Array([Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)])

var tiles = {}
var tilemap_walkable
var tilemap_buildable

var tile_type_override = {
	"wall_s": Tile.TILE_SOLID,
	"wall_e": Tile.TILE_SOLID,
	"wall_w": Tile.TILE_SOLID
}

func _ready():
	tilemap_walkable = get_node("tilemap_grass")
	tilemap_buildable = get_node("tilemap_tower")
	update_tiles()

func update_tiles():
	tiles = {}
	import_tilemap(tilemap_walkable, Tile.TILE_WALKABLE)
	import_tilemap(tilemap_buildable, Tile.TILE_SOLID)
	
#	for cell in tiles:
#		var tile = tiles[cell] 
#		new_tile.type = tile_types[ tilemap.get_cell(cell.x, cell.y) ]
#		
#		for direction in DIRECTIONS:
#			var direction_cell = cell + direction
#			var direction_tile_type = tilemap.get_cell(direction_cell.x, direction_cell.y)
#			if direction_tile_type > 0 and tile_types[direction_tile_type] == Tile.TILE_WALKABLE:
#				new_tile.possible_directions.push_back(direction)

func import_tilemap(tilemap, default_tile_type):
	var tileset = tilemap.get_tileset()
	for cell in tilemap.get_used_cells():
		var new_tile = Tile.new()
		var cell_type = tilemap.get_cell(cell.x, cell.y)
		var cell_name = tileset.tile_get_name(cell_type)
		if tile_type_override.has(cell_name):
			new_tile.type = tile_type_override[cell_name]
			print(true)
		else:
			new_tile.type = default_tile_type
		
		tiles[cell] = new_tile

