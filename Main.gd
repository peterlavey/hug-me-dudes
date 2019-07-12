extends Node

var Game = load("res://src/game/game.gd")

func _ready():
	add_child(Game.new())