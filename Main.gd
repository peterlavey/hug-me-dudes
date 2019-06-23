extends Node

onready var player = preload("res://src/player.tscn")


func _ready():
	player = player.instance()
	
	print(player.nickname)
	
	player.set_nickname("Test")
	
	print(player.nickname)
	print(player.status.health)
	
	set_process(true)
	
	
	
	

