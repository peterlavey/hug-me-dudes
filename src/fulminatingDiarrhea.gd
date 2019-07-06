class_name FulminatingDiarrhea extends "res://src/disease.gd"

const LIFE_EXPECTANCY:int = 2

func _ready():
	set_desease()
	start(LIFE_EXPECTANCY)
	pass

func death() -> void:
	print("DEATH")
	
	pass

func set_desease() -> void:
	var players = get_tree().get_nodes_in_group("players")
	
	players[0].modulate = "4d732a"
	#players[0].set_texture(load("res://sprites/icon2.png"))
	
	pass
