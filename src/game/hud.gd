class_name Hud extends CanvasLayer

var textWin: TextWin = load("res://src/game/textWin.gd").new()
var countdown: CountdownHud = load("res://src/game/countdownHud.gd").new()
var match_countdown: MatchCountdown = load("res://src/game/match_countdown.gd").new()

func _ready() -> void:
	config_match_countdown()
	config_countdown()
	config_text_win()

func config_match_countdown() -> void:
	add_child(match_countdown)

func config_countdown() -> void:
	add_child(countdown)

func config_text_win() -> void:
	add_child(textWin)