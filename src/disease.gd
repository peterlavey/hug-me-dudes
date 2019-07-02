class_name Diseases extends Node2D

var input:TextEdit
var timer:Timer
var timeLeft:float

func _init():
	config_timer()
	config_input()
	
	pass

func _process(delta) -> void:
	show_time_left()
	
	pass
	
func set_desease() -> void:
	var players = get_tree().get_nodes_in_group("players")
	
	players[0].modulate = "99FF99"
	#players[0].set_texture(load("res://sprites/icon2.png"))
	
	pass

func show_time_left() -> void:
	timeLeft = timer.get_time_left()
	input.set_text(str(stepify(timeLeft, 0.01)))
	
	pass

func config_input() -> void:
	input = TextEdit.new()
	input.rect_size.x = 100
	input.rect_size.y = 20
	
	add_child(input)
	
	pass

func config_timer() -> void:
	timer = Timer.new()
	#timer.set_autostart(true)
	timer.set_one_shot(true)
	timer.set_wait_time(3)
	timer.connect("timeout", self, "set_desease")
	timer.start()
	
	add_child(timer)
	
	pass