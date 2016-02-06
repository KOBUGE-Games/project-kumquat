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
	pass

### Functions

func go_to_level(level):
	get_tree().change_scene_to(preload("res://main/game.tscn"))
