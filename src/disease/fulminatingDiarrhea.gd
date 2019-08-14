class_name FulminatingDiarrhea extends "res://src/disease/disease.gd"

const _name = "FulminatingDiarrhea"
var Diarrhea = preload("res://particles/Diarrhea.tscn")
var diarrhea
const LIFE_EXPECTANCY:int = 5

func _ready():
	diarrhea = Diarrhea.instance()
	start_effects()
	start(LIFE_EXPECTANCY)
	pass

func dead() -> void:
	afflicted.dead()
	afflicted._animation.modulate = "2d7550"
	pass

func remove_effects() -> void:
	afflicted._animation.modulate = "ffffff"
	diarrhea.queue_free()
	pass

func start_effects() -> void:
	afflicted._animation.modulate = "4d732a"
	afflicted.add_child(diarrhea)
	pass
