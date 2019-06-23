extends Node

#var test = preload("res://src/body.gd")
var Player = preload("res://src/Player.tscn")
var Body = preload("res://src/body.gd")

func _ready():
	var player = Player.instance()
	add_child(player)

