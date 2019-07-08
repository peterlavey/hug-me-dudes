class_name FulminatingDiarrhea extends "res://src/disease/disease.gd"

const LIFE_EXPECTANCY:int = 8

func _ready():
	start_effects()
	start(LIFE_EXPECTANCY)
	pass

func death() -> void:
	afflicted.queue_free()
	pass

func remove_effects() -> void:
	afflicted.modulate = "ffffff"
	pass

func start_effects() -> void:
	afflicted.modulate = "4d732a"
	pass
