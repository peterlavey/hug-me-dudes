class_name Disease extends Node2D

var input: TextEdit
var timer: Timer
var timeLeft: float
var afflicted: CharacterBody2D

func _init() -> void:
	config_timer()
	config_input()

func _process(delta: float) -> void:
	show_time_left()

func show_time_left() -> void:
	if timer:
		timeLeft = timer.get_time_left()
		if input:
			input.set_text(str(snapped(timeLeft, 0.01)))

func remove_time_left() -> void:
	if input and input.get_parent() == self:
		remove_child(input)
	if timer:
		timer.stop()

func config_input() -> void:
	input = TextEdit.new()
	input.size.x = 50
	input.size.y = 20
	
	add_child(input)

func config_timer() -> void:
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", Callable(self, "dead"))
	add_child(timer)

func start(seconds: float) -> void:
	timer.set_wait_time(seconds)
	timer.start()

func dead() -> void:
	pass

func remove_effects() -> void:
	pass

func start_effects() -> void:
	pass
	