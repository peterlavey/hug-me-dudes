class_name DiseaseRandomizer extends GDScript

var SpontaneousCombustion = load("res://src/spontaneousCombustion.gd")
var FulminatingDiarrhea = load("res://src/fulminatingDiarrhea.gd")

var DISEASES:Array = [
	SpontaneousCombustion,
	FulminatingDiarrhea
]

func get_disease()-> Disease:
	return DISEASES[random()].new()
	pass

func random()-> int:
	return 0#randi() % DISEASES.size()
	pass