extends Node

var game = load("res://src/game/game.gd").new()
var menu = load("res://src/game/menu.gd").new()
var stageSelect = load("res://src/game/stageSelect.gd").new()
var transition = load("res://src/game/transition.gd").new()
var world:Node

func _ready():
	config_world()
	#config_menu()
	config_stage_select()
	config_transition()

func config_world()-> void:
	world = Node.new()
	add_child(world)

func config_transition()-> void:
	transition.connect("on_blackout", self, "init_game")
	add_child(transition)

func config_menu():
	menu.connect("on_menu_start", self, "start_game")
	world.add_child(menu)
	
	transition.speed = 3
	transition.dark_to_light()

func config_stage_select()-> void:
	world.add_child(stageSelect)

func start_game():
	transition()

func transition():
	transition.speed = 8
	transition.light_to_dark_to_light()

func init_game()-> void:
	world.remove_child(menu)
	world.add_child(game)