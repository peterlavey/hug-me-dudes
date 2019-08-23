extends Node

var game = load("res://src/game/game.gd").new()
var menu = load("res://src/game/menu.gd").new()

func _ready():
	add_child(menu)