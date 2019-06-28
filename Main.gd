extends Node

var Player = load("res://src/player.gd")
var Stage = preload("res://stages/Stage.tscn")

func _ready():
	var player1 = Player.new()
	var player2 = Player.new()
	var stage = Stage.instance()
	
	player1._id = 1
	player1.texture = load("res://sprites/icon.png")
	player1.position.x = 400
	player1.position.y = 0
	
	player2._id = 2
	player2.texture = load("res://sprites/icon2.png")
	player2.position.x = 600
	player2.position.y = 0
	
	add_child(stage)
	add_child(player1)
	add_child(player2)

