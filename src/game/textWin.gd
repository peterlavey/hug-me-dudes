class_name TextWin extends Node2D

var input:TextEdit

func _ready():
	config_input()

func config_input() -> void:
	input = TextEdit.new()
	
	input.readonly = true
	
	add_child(input)
	
	pass

func show_winner(winner:String) -> void:
	input.rect_size.x = 120
	input.rect_size.y = 20
	input.set_text(winner + " wins!!")

func remove_winner() -> void:
	input.rect_size.x = 0
	input.rect_size.y = 0
	input.set_text("")