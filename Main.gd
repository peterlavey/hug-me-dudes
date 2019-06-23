extends Node

var test = preload("res://src/body.gd")

func _ready():
	test = test.new()
	
	print(test.edad)

	add_child(test)
	
	set_process(true)

