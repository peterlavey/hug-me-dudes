extends Node

onready var player = preload("res://characters/Player.tscn")
onready var stage = preload("res://stages/Stage1.tscn")

var globalVar;

func _ready():	
	set_process(true)

	add_child(player.instance())
	test()

	add_child(stage.instance())

func test():
	print("asdasdasd")
	

