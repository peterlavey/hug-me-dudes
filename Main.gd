extends Node

var Player = preload("res://src/Player.tscn")

func _ready():
	var player = Player.instance()
	add_child(player)