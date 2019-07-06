class_name Disease extends Node2D

var input:TextEdit
var timer:Timer
var timeLeft:float
var afflicted:KinematicBody2D

func _init():
	config_timer()
	config_input()
	
	pass

func _process(delta) -> void:
	show_time_left()
	
	pass

func show_time_left() -> void:
	timeLeft = timer.get_time_left()
	input.set_text(str(stepify(timeLeft, 0.01)))
	
	pass

func config_input() -> void:
	input = TextEdit.new()
	input.rect_size.x = 50
	input.rect_size.y = 20
	
	add_child(input)
	
	pass

func config_timer() -> void:
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", self, "death")
	
	pass

func start(seconds:int) -> void:
	#config_timer()
	#config_input()
	timer.set_wait_time(seconds)
	timer.start()
	
	add_child(timer)
	pass
	