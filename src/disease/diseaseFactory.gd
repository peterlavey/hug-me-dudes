class_name DiseaseFactory extends GDScript

var SpontaneousCombustion = load("res://src/disease/spontaneousCombustion.gd")
var FulminatingDiarrhea = load("res://src/disease/fulminatingDiarrhea.gd")

var DISEASES:Array = [
	SpontaneousCombustion,
	FulminatingDiarrhea
]

func get_random_disease()-> Disease:
	return DISEASES[random()].new()
	pass

func get_disease(name:String)-> Disease:
	var _disease:Disease
	
	for disease in DISEASES:
		if disease._name == name:
			_disease = disease.new()
			break
	
	return _disease
	pass

func random()-> int:
	return randi() % DISEASES.size()
	pass