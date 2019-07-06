extends Node

var Player = load("res://src/player.gd")
var Stage = preload("res://stages/Stage.tscn")
var DiseaseRandomizer = load("res://src/diseaseRandomizer.gd").new()
#var Disease = load("res://src/disease.gd")
#var SpontaneousCombustion = load("res://src/spontaneousCombustion.gd")

func _ready():
	var player1 = Player.new()
	var player2 = Player.new()
	var stage = Stage.instance()
	var disease = DiseaseRandomizer.get_disease()
	
	player1._id = 1
	player1.animation = load("res://characters/Peter.tscn")
	player1.position.x = 400
	player1.position.y = 0
	
	player2._id = 2
	player2.animation = load("res://characters/Peter.tscn")
	player2.position.x = 600
	player2.position.y = 0
	#player2.modulate = "ff7098"
	
	disease.position.x = 450
	disease.position.y = 50
	
	add_child(stage)
	add_child(player1)
	add_child(player2)
	
	#player1.load_texture(load("res://sprites/icon2.png"))
	#player1.body.texture = load("res://sprites/icon2.png")
	#print(get_child(1))
	#get_child(1).texture = load("res://sprites/icon2.png")
	add_child(disease)
	

