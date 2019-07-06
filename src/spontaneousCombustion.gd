class_name SpontaneousCombustion extends "res://src/disease.gd"

var fire = preload("res://particles/Fire.tscn")
const LIFE_EXPECTANCY:int = 3

func _ready():
	set_desease()
	start(LIFE_EXPECTANCY)
	pass

func death() -> void:
	print("DEATH")
	afflicted.queue_free()
	pass

func set_desease() -> void:
	afflicted.add_child(fire.instance())
	pass
