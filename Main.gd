extends Node

var game = load("res://src/game/game.gd").new()
var menu = load("res://src/game/menu.gd").new()
var stageSelect = load("res://src/game/stageSelect.gd").new()
var transition = load("res://src/game/transition.gd").new()
var timer = Timer.new()
var currentStage
var world:Node

func _ready():
	config_world()
	config_menu()
	#config_stage_select()
	config_transition()

func config_world()-> void:
	world = Node.new()
	add_child(world)

func config_transition()-> void:
	transition.connect("on_blackout", Callable(self, "init_game"))
	add_child(transition)

func config_menu():
	menu.connect("on_menu_start", Callable(self, "skip_story"))
	world.add_child(menu)
	
	transition.speed = 3
	transition.dark_to_light()

func skip_story()-> void:
	add_child(timer)
	timer.connect("timeout", Callable(self, "config_stage_select"))
	timer.set_one_shot(true)
	timer.start(0.5)

func config_stage_select()-> void:
	stageSelect.connect("on_selected_stage", Callable(self, "start_game"))
	world.remove_child(menu)
	world.add_child(stageSelect)

func start_game(_currentStage):
	currentStage = _currentStage
	start_transition()

func start_transition()-> void:
	transition.speed = 8
	transition.light_to_dark_to_light()

func init_game()-> void:
	game.stage = currentStage
	world.remove_child(stageSelect)
	world.add_child(game)