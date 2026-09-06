class_name Disease extends Node2D

var timer: Timer
var timeLeft: float = 0.0
var total_duration: float = 5.0
var afflicted: CharacterBody2D

signal time_updated(time_left: float, total_time: float)
signal disease_stopped

func _init() -> void:
	config_timer()

func _process(_delta: float) -> void:
	show_time_left()

func show_time_left() -> void:
	if timer and timer.time_left > 0:
		timeLeft = timer.get_time_left()
		time_updated.emit(timeLeft, total_duration)

func remove_time_left() -> void:
	if timer:
		timer.stop()
	disease_stopped.emit()

func config_timer() -> void:
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", Callable(self, "dead"))
	add_child(timer)

func start(seconds: float) -> void:
	total_duration = seconds
	timeLeft = seconds
	if timer:
		timer.set_wait_time(seconds)
		timer.start()

func dead() -> void:
	pass

func remove_effects() -> void:
	pass

func start_effects() -> void:
	pass
	