class_name SpontaneousCombustion extends "res://src/disease.gd"

var fire = preload("res://particles/Fire.tscn")
const LIFE_EXPECTANCY:int = 3

func _ready():
	start(LIFE_EXPECTANCY)
	pass

func set_desease() -> void:
	var players = get_tree().get_nodes_in_group("players")
	
	players[0].add_child(fire.instance())
	
	pass
