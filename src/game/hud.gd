class_name Hud extends CanvasLayer

var textWin: TextWin = load("res://src/game/textWin.gd").new()

func _ready() -> void:
	config_text_win()

func config_text_win() -> void:
	add_child(textWin)