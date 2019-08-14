class_name Game extends Node2D

var Player = load("res://src/player/player.gd")
var Stage = preload("res://stages/Ship.tscn")

var diseaseFactory = load("res://src/disease/diseaseFactory.gd").new()
var playlist = load("res://src/playlist/playlist.gd").new()
var camera = load("res://src/game/camera.gd").new()
var hud = load("res://src/game/hud.gd").new()

var players:Array
var timerDisease:Timer
var timerWinner:Timer

func _ready():
	init()

func init()-> void:
	add_stage()
	add_music()
	add_players()
	add_disease()
	set_random_disease()
	configurations()

func configurations()-> void:
	config_signals()
	config_hud()

func config_hud()-> void:
	add_child(hud)

func set_random_disease()-> void:
	timerDisease.start()

func add_disease()-> void:
	config_timer()

func add_music()-> void:
	add_child(playlist)
	
	playlist.play()

func add_stage()-> void:
	add_child(Stage.instance())

func add_players()-> void:
	var player1 = Player.new()
	var player2 = Player.new()
	var player3 = Player.new()
	var player4 = Player.new()
	
	player1._id = 1
	player1.nickname = "Peter"
	player1.animation = load("res://src/characters/Peter.tscn")
	player1.position.x = 300
	player1.position.y = 200
	
	player2._id = 2
	player2.nickname = "Kenny"
	player2.animation = load("res://src/characters/Peter.tscn")
	player2.position.x = 500
	player2.position.y = 200
	
	player3._id = 3
	player3.nickname = "Bestian"
	player3.animation = load("res://src/characters/Peter.tscn")
	player3.position.x = 700
	player3.position.y = 200
	
	player4._id = 4
	player4.nickname = "Wyrm"
	player4.animation = load("res://src/characters/Peter.tscn")
	player4.position.x = 900
	player4.position.y = 200
	
	add_child(player1)
	add_child(player2)
	#add_child(player3)
	#add_child(player4)
	
	players = get_tree().get_nodes_in_group("players")

func config_timer()-> void:
	timerDisease = Timer.new()
	timerDisease.set_one_shot(true)
	timerDisease.set_wait_time(1)
	timerDisease.connect("timeout", self, "set_disease")
	
	add_child(timerDisease)
	
	timerWinner = Timer.new()
	timerWinner.set_one_shot(true)
	timerWinner.set_wait_time(5)
	timerWinner.connect("timeout", self, "reload")
	
	add_child(timerWinner)
	
	pass

func set_disease()-> void:
	var disease = diseaseFactory.get_random_disease()
	
	disease.position.x = -20
	disease.position.y = -150
	
	players[randi() % players.size()].set_disease(disease)

func config_signals()-> void:
	for player in players:
		player.connect("on_died", self, "on_player_died")

func on_player_died(player:KinematicBody2D)-> void:
	players.erase(player)
	verify_players(player)

func verify_players(player:KinematicBody2D)-> void:
	if players.size() == 1:
		for winner in players:
			game_over(winner)
	elif player.status.isAfflicted:
		set_random_disease()

func game_over(winner)-> void:
	if winner.status.isAfflicted:
		winner.cured()
		
	show_winner(winner)

func show_winner(winner)-> void:
	hud.textWin.show_winner(winner.nickname)
	
	camera.set_zoom(Vector2(0.5, 0.5))
	winner.add_child(camera)
	camera.make_current()
	
	timerWinner.start()

func reload()-> void:
	get_tree().reload_current_scene()