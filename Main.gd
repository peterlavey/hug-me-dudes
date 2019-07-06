extends Node

var Player = load("res://src/player.gd")
var Stage = preload("res://stages/Stage.tscn")
var DiseaseRandomizer = load("res://src/diseaseRandomizer.gd").new()
var song = preload("res://sounds/song.ogg")

var timer:Timer

func _ready():
	var player1 = Player.new()
	var player2 = Player.new()
	var stage = Stage.instance()
	var audioStream = AudioStreamPlayer2D.new()
	
	audioStream.stream = song
	#audioStream.autoplay = true
	
	player1._id = 1
	player1.animation = load("res://characters/Peter.tscn")
	player1.position.x = 400
	player1.position.y = 0
	
	player2._id = 2
	player2.animation = load("res://characters/Peter.tscn")
	player2.position.x = 600
	player2.position.y = 0
	
	add_child(stage)
	add_child(player1)
	add_child(player2)
	add_child(audioStream)
	
	config_timer()

func config_timer() -> void:
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(1)
	timer.connect("timeout", self, "set_disease")
	
	timer.start()
	
	add_child(timer)
	
	pass

func set_disease()-> void:
	var disease = DiseaseRandomizer.get_disease()
	var players = get_tree().get_nodes_in_group("players")
	
	disease.position.x = -20
	disease.position.y = -150
	
	players[randi() % players.size()].set_disease(disease)
