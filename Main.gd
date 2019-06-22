extends Node

onready var player = preload("res://characters/Player.tscn")
onready var player2 = preload("res://characters/Player2.tscn")
onready var stage = preload("res://stages/Stage1.tscn")

#gitflow test
func _ready():
	set_process(true)
	add_child(player.instance())
	add_child(player2.instance())
	add_child(stage.instance())
