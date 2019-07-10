extends Node

var Player = load("res://src/player/player.gd")
var Stage = preload("res://stages/Ship.tscn")
var DiseaseRandomizer = load("res://src/disease/diseaseRandomizer.gd").new()
var song = preload("res://sounds/song.ogg")
var Playlist = load("res://src/playlist/playlist.gd")
var MusicPlayer = load("res://src/musicPlayer.gd")

var timer:Timer

func _ready():
	get_viewport().set_size_override(true, Vector2(1366, 768))
	var player1 = Player.new()
	var player2 = Player.new()
	var stage = Stage.instance()
	
	var playlist = Playlist.new()
	playlist.play()
	
	player1._id = 1
	player1.animation = load("res://characters/Peter.tscn")
	player1.position.x = 300
	player1.position.y = 200
	
	player2._id = 2
	player2.animation = load("res://characters/Peter.tscn")
	player2.position.x = 900
	player2.position.y = 200
	
	add_child(stage)
	add_child(player1)
	add_child(player2)
	add_child(playlist)
	
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
