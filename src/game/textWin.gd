class_name TextWin extends Node2D

var input:TextEdit

func _ready():
	config_input()

func config_input() -> void:
	input = TextEdit.new()
	
	input.editable = false
	
	add_child(input)
	
	pass

func show_winner(winner:String) -> void:
	input.size.x = 120
	input.size.y = 20
	input.set_text(winner + " wins!!")

func remove_winner() -> void:
	input.size.x = 0
	input.size.y = 0
	input.set_text("")