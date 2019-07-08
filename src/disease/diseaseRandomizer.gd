class_name DiseaseRandomizer extends GDScript

var SpontaneousCombustion = load("res://src/disease/spontaneousCombustion.gd")
var FulminatingDiarrhea = load("res://src/disease/fulminatingDiarrhea.gd")

var DISEASES:Array = [
	SpontaneousCombustion,
	FulminatingDiarrhea
]

func get_disease()-> Disease:
	return DISEASES[random()].new()
	pass

func random()-> int:
	return randi() % DISEASES.size()
	pass