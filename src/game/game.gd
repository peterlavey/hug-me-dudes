class_name Game extends Node

var Player = load("res://src/player/player.gd")
var Stage = preload("res://stages/Ship.tscn")
var DiseaseFactory = load("res://src/disease/diseaseFactory.gd").new()
var Playlist = load("res://src/playlist/playlist.gd")

var stage
var playlist

var players:Array

var timer:Timer

func _ready():
	init()

func init()-> void:
	add_stage()
	add_music()
	add_players()
	add_disease()
	set_random_disease()
	config_signals()

func set_random_disease()-> void:
	timer.start()

func add_disease()-> void:
	config_timer()

func add_music()-> void:
	playlist = Playlist.new()
	playlist.play()
	
	add_child(playlist)

func add_stage()-> void:
	stage = Stage.instance()
	
	add_child(stage)

func add_players()-> void:
	var player1 = Player.new()
	var player2 = Player.new()
	var player3 = Player.new()
	var player4 = Player.new()
	
	player1._id = 1
	player1.animation = load("res://characters/Peter.tscn")
	player1.position.x = 300
	player1.position.y = 200
	
	player2._id = 2
	player2.animation = load("res://characters/Peter.tscn")
	player2.position.x = 500
	player2.position.y = 200
	
	player3._id = 3
	player3.animation = load("res://characters/Peter.tscn")
	player3.position.x = 700
	player3.position.y = 200
	
	player4._id = 4
	player4.animation = load("res://characters/Peter.tscn")
	player4.position.x = 900
	player4.position.y = 200
	
	add_child(player1)
	add_child(player2)
	add_child(player3)
	add_child(player4)
	
	players = get_tree().get_nodes_in_group("players")

func config_timer()-> void:
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(1)
	timer.connect("timeout", self, "set_disease")
	
	add_child(timer)
	
	pass

func set_disease()-> void:
	var disease = DiseaseFactory.get_random_disease()
	
	disease.position.x = -20
	disease.position.y = -150
	
	players[randi() % players.size()].set_disease(disease)

func config_signals()-> void:
	for player in players:
		player.connect("on_died", self, "on_player_died")

func on_player_died(player:KinematicBody2D, hadDisease:bool)-> void:
	players.erase(player)
	
	if players.size() == 1:
		game_over()
	
	if hadDisease:
		set_random_disease()

func game_over()-> void:
	get_tree().reload_current_scene()