extends Node

var game = load("res://src/game/game.gd").new()
var menu = load("res://src/game/menu.gd").new()
var transition = load("res://src/game/transition.gd").new()

func _ready():
	config_menu()
	config_transition()

func config_transition()-> void:
	add_child(transition)

func config_menu():
	menu.connect("on_menu_start", self, "start_game")
	add_child(menu)
	
	transition.light_to_dark_to_light()

func start_game():
	remove_child(menu)
	add_child(game)