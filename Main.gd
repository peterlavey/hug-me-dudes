extends Node

onready var player = preload("res://src/Player.tscn")


func _ready():
	player = player.instance()
	
	print(player._name)
	
	player.set_name("Test")
	
	print(player._name)
	set_process(true)
	
	print(player._status)

