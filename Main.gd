extends Node

var game: Game = null
var menu = load("res://src/game/menu.gd").new()
var stage_select_scene: PackedScene = preload("res://src/game/stage_select.tscn")
var stageSelect: StageSelect = null
var transition = load("res://src/game/transition.gd").new()
var victory_scene: VictoryScene = null

var timer: Timer = Timer.new()
var currentStage: String = ""
var world: Node = Node.new()

@export var target_wins: int = 3

func _ready() -> void:
	config_world()
	config_menu()
	config_transition()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11 or (event.keycode == KEY_ENTER and event.alt_pressed):
			toggle_fullscreen()

func toggle_fullscreen() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func config_world() -> void:
	if world.get_parent() == null:
		add_child(world)

func config_transition() -> void:
	transition.connect("on_blackout", Callable(self, "init_game"))
	add_child(transition)

func config_menu() -> void:
	if not menu.is_connected("on_menu_start", Callable(self, "skip_story")):
		menu.connect("on_menu_start", Callable(self, "skip_story"))
	if menu.get_parent() == null:
		world.add_child(menu)
	
	transition.speed = 3
	transition.dark_to_light()

func skip_story() -> void:
	if timer.get_parent() == null:
		add_child(timer)
	if not timer.is_connected("timeout", Callable(self, "config_stage_select")):
		timer.connect("timeout", Callable(self, "config_stage_select"))
	timer.set_one_shot(true)
	timer.start(0.5)

func config_stage_select() -> void:
	if menu != null and is_instance_valid(menu) and menu.get_parent() == world:
		world.remove_child(menu)
	
	if stageSelect == null or not is_instance_valid(stageSelect):
		stageSelect = stage_select_scene.instantiate() as StageSelect
		stageSelect.connect("on_selected_stage", Callable(self, "start_game"))
		stageSelect.connect("back_requested", Callable(self, "on_return_to_menu"))
	
	if stageSelect.has_method("reset"):
		stageSelect.reset()
	
	if stageSelect.get_parent() == null:
		world.add_child(stageSelect)

func start_game(_currentStage: String) -> void:
	currentStage = _currentStage
	start_transition()

func start_transition() -> void:
	transition.speed = 8
	transition.light_to_dark_to_light()

func init_game() -> void:
	if stageSelect != null and is_instance_valid(stageSelect) and stageSelect.get_parent() == world:
		world.remove_child(stageSelect)
	
	if game != null and is_instance_valid(game):
		if game.get_parent() == world:
			world.remove_child(game)
		game.queue_free()
	
	game = load("res://src/game/game.gd").new()
	game.target_wins = target_wins
	game.stage = currentStage
	game.connect("match_won", Callable(self, "show_match_victory"))
	
	world.add_child(game)

func show_match_victory(winner_data: Dictionary, scores: Dictionary, wins_needed: int) -> void:
	var victory_timer: SceneTreeTimer = get_tree().create_timer(2.4)
	victory_timer.timeout.connect(func():
		_transition_to_victory_scene(winner_data, scores, wins_needed)
	)

func _transition_to_victory_scene(winner_data: Dictionary, scores: Dictionary, wins_needed: int) -> void:
	if game != null and is_instance_valid(game) and game.get_parent() == world:
		world.remove_child(game)
	
	if victory_scene != null and is_instance_valid(victory_scene):
		if victory_scene.get_parent() == world:
			world.remove_child(victory_scene)
		victory_scene.queue_free()
	
	victory_scene = load("res://src/game/victory_scene.gd").new()
	victory_scene.setup(winner_data, scores, wins_needed)
	victory_scene.connect("play_again_requested", Callable(self, "on_play_again"))
	victory_scene.connect("menu_requested", Callable(self, "on_return_to_menu"))
	
	world.add_child(victory_scene)

func on_play_again() -> void:
	if victory_scene != null and is_instance_valid(victory_scene):
		if victory_scene.get_parent() == world:
			world.remove_child(victory_scene)
		victory_scene.queue_free()
		victory_scene = null
	
	init_game()

func on_return_to_menu() -> void:
	if stageSelect != null and is_instance_valid(stageSelect):
		if stageSelect.get_parent() == world:
			world.remove_child(stageSelect)
	
	if victory_scene != null and is_instance_valid(victory_scene):
		if victory_scene.get_parent() == world:
			world.remove_child(victory_scene)
		victory_scene.queue_free()
		victory_scene = null
	
	if game != null and is_instance_valid(game):
		if game.get_parent() == world:
			world.remove_child(game)
		game.queue_free()
		game = null
	
	# Restaurar menú
	if menu.has_method("reset"):
		menu.reset()
	else:
		menu.isInitiated = false
	
	if menu.get_parent() == null:
		world.add_child(menu)
	
	transition.speed = 3
	transition.dark_to_light()
