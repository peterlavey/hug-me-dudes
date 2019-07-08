class_name SpontaneousCombustion extends "res://src/disease/disease.gd"

var Fire = preload("res://particles/Fire.tscn")
var fire
const LIFE_EXPECTANCY:int = 6

func _ready():
	fire = Fire.instance()
	start_effects()
	start(LIFE_EXPECTANCY)
	pass

func death() -> void:
	print("DEATH")
	afflicted.queue_free()
	pass

func remove_effects() -> void:
	fire.queue_free()
	pass

func start_effects() -> void:
	afflicted.add_child(fire)
	pass
