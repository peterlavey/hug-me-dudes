class_name Hud extends CanvasLayer

var textWin = load("res://src/game/textWin.gd").new()

func _ready():
	config_text_win()

func config_text_win()-> void:
	textWin.position.x = 500
	textWin.position.y = 50
	
	add_child(textWin)