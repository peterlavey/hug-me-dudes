class_name FulminatingDiarrhea extends "res://src/disease.gd"

const LIFE_EXPECTANCY:int = 2

func _ready():
	set_desease()
	start(LIFE_EXPECTANCY)
	pass

func death() -> void:
	print("DEATH")
	afflicted.queue_free()
	pass

func set_desease() -> void:
	afflicted.modulate = "4d732a"
	pass
