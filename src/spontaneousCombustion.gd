class_name SpontaneousCombustion extends "res://src/disease.gd"

const LIFE_EXPECTANCY:int = 3

func _ready():
	start(LIFE_EXPECTANCY)
	pass

func set_desease() -> void:
	var players = get_tree().get_nodes_in_group("players")
	
	players[0].modulate = "dd6516"
	#players[0].set_texture(load("res://sprites/icon2.png"))
	
	pass
