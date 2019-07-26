extends Node

var Game = load("res://src/game/game.gd")
var game

func _ready():
	game = Game.new()
	add_child(game)