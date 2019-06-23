extends Node

#var test = preload("res://src/body.gd")
var player_class = preload("res://src/Player.tscn")

func _ready():
	var player = player_class.instance()
	add_child(player)

