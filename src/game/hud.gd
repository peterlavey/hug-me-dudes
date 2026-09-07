class_name Hud extends CanvasLayer

var textWin: TextWin = load("res://src/game/textWin.gd").new()
var countdown: CountdownHud = load("res://src/game/countdownHud.gd").new()
var match_countdown: MatchCountdown = load("res://src/game/match_countdown.gd").new()
var score_hud: ScoreHud = load("res://src/game/score_hud.gd").new()
var disease_announcement: DiseaseAnnouncement = load("res://src/game/disease_announcement.gd").new()

func _ready() -> void:
	config_match_countdown()
	config_countdown()
	config_disease_announcement()
	config_text_win()
	config_score_hud()

func config_match_countdown() -> void:
	add_child(match_countdown)

func config_countdown() -> void:
	add_child(countdown)

func config_disease_announcement() -> void:
	add_child(disease_announcement)

func config_text_win() -> void:
	add_child(textWin)

func config_score_hud() -> void:
	add_child(score_hud)