class_name DiseaseFactory extends RefCounted

var SpontaneousCombustion = load("res://src/disease/spontaneousCombustion.gd")
var FulminatingDiarrhea = load("res://src/disease/fulminatingDiarrhea.gd")

var DISEASES: Array = [
	SpontaneousCombustion,
	FulminatingDiarrhea
]

func get_random_disease() -> Disease:
	return DISEASES[random()].new()

func get_disease(name: String) -> Disease:
	var _disease: Disease
	
	for disease in DISEASES:
		if disease._name == name:
			_disease = disease.new()
			break
	
	return _disease

func random() -> int:
	return randi() % DISEASES.size()