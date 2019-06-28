extends Node

var Player = load("res://src/player.gd")
var Stage = preload("res://stages/Stage1.tscn")

onready var texture = load("res://sprites/icon.png") 

func _ready():
	var player = Player.new()
	var player2 = Player.new()
	
	var stage = Stage.instance()
	
	player2._id = 2
	player2.texture = texture
	
	
	add_child(stage)
	add_child(player2)
	#add_child(player2)