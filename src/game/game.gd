class_name Game extends Node

var Player = load("res://src/player/player.gd")
var Stage = preload("res://stages/Ship.tscn")
var DiseaseRandomizer = load("res://src/disease/diseaseRandomizer.gd").new()
var Playlist = load("res://src/playlist/playlist.gd")
var MusicPlayer = load("res://src/musicPlayer.gd")

var timer:Timer

func _ready():
	add_stage()
	add_music()
	add_players()
	add_disease()
	set_random_disease()

func set_random_disease()-> void:
	timer.start()

func add_disease()-> void:
	config_timer()

func add_music()-> void:
	var playlist = Playlist.new()
	playlist.play()
	
	add_child(playlist)

func add_stage()-> void:
	var stage = Stage.instance()
	
	add_child(stage)

func add_players()-> void:
	var player1 = Player.new()
	var player2 = Player.new()
	
	player1._id = 1
	player1.animation = load("res://characters/Peter.tscn")
	player1.position.x = 300
	player1.position.y = 200
	
	player2._id = 2
	player2.animation = load("res://characters/Peter.tscn")
	player2.position.x = 900
	player2.position.y = 200
	
	add_child(player1)
	add_child(player2)

func config_timer()-> void:
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(1)
	timer.connect("timeout", self, "set_disease")
	
	add_child(timer)
	
	pass

func set_disease()-> void:
	var disease = DiseaseRandomizer.get_disease()
	var players = get_tree().get_nodes_in_group("players")
	
	disease.position.x = -20
	disease.position.y = -150
	
	players[randi() % players.size()].set_disease(disease)

