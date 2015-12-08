extends Node

### Variables

# Consts
const TILE_SIZE = 32
const TILE_OFFSET = Vector2(0.5, 0.5)*TILE_SIZE

# Nodes
var game
var level
var hud

### Callbacks

func _ready():
	game = get_node("/root/game")
	level = game.get_node("level")
	hud = game.get_node("hud")
