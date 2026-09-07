class_name Game extends Node2D

signal round_won(winner: CharacterBody2D, current_wins: int, target_wins: int)
signal match_won(winner_data: Dictionary, scores: Dictionary, target_wins: int)
signal score_updated(scores: Dictionary)

var Player = load("res://src/player/player.gd")
var diseaseFactory = load("res://src/disease/diseaseFactory.gd").new()
var playlist = load("res://src/playlist/playlist.gd").new()
var camera: CustomCamera = load("res://src/game/camera.gd").new()
var hud: Hud = load("res://src/game/hud.gd").new()

@export var target_wins: int = 3
var current_round: int = 1
var scores: Dictionary = { 1: 0, 2: 0, 3: 0, 4: 0 }
var is_round_active: bool = false
var is_match_over: bool = false

var stage: String
var current_stage_node: Node = null
var players: Array = []
var active_player_nodes: Array = []

var timerDisease: Timer
var timerRoundEnd: Timer
var timerMatchEnd: Timer

const PLAYER_DEFAULTS: Array[Dictionary] = [
	{ "id": 1, "nickname": "Peter", "character": "res://src/characters/Peter.tscn", "x": 300.0, "y": 200.0 },
	{ "id": 2, "nickname": "Kenny", "character": "res://src/characters/Kenny.tscn", "x": 500.0, "y": 200.0 },
	{ "id": 3, "nickname": "Bestian", "character": "res://src/characters/Bestian.tscn", "x": 700.0, "y": 200.0 },
	{ "id": 4, "nickname": "Wyrm", "character": "res://src/characters/Wyrm.tscn", "x": 900.0, "y": 200.0 }
]

func _ready() -> void:
	init()

func init() -> void:
	reset_scores()
	add_music()
	config_timers()
	config_hud()
	start_round()

func reset_scores() -> void:
	scores.clear()
	for p_info in PLAYER_DEFAULTS:
		scores[int(p_info["id"])] = 0
	current_round = 1
	is_match_over = false

func config_timers() -> void:
	if timerDisease == null:
		timerDisease = Timer.new()
		timerDisease.set_one_shot(true)
		timerDisease.set_wait_time(1.0)
		timerDisease.connect("timeout", Callable(self, "set_disease"))
		add_child(timerDisease)
	
	if timerRoundEnd == null:
		timerRoundEnd = Timer.new()
		timerRoundEnd.set_one_shot(true)
		timerRoundEnd.set_wait_time(3.0)
		timerRoundEnd.connect("timeout", Callable(self, "start_round"))
		add_child(timerRoundEnd)
	
	if timerMatchEnd == null:
		timerMatchEnd = Timer.new()
		timerMatchEnd.set_one_shot(true)
		timerMatchEnd.set_wait_time(3.2)
		timerMatchEnd.connect("timeout", Callable(self, "_on_match_end_timeout"))
		add_child(timerMatchEnd)

func config_hud() -> void:
	if hud.get_parent() == null:
		add_child(hud)
	hud.score_hud.setup_players(PLAYER_DEFAULTS, target_wins)
	hud.score_hud.update_scores(scores, target_wins)

func add_music() -> void:
	if playlist.get_parent() == null:
		add_child(playlist)
		playlist.play()

func start_round() -> void:
	if is_match_over:
		return
	
	is_round_active = false
	
	# Detener temporizadores de ronda
	if timerDisease:
		timerDisease.stop()
	if timerRoundEnd:
		timerRoundEnd.stop()
	
	# Limpiar estado anterior
	_cleanup_round()
	
	# Reinstanciar escenario
	add_stage()
	
	# Reinstanciar jugadores
	spawn_players()
	
	# Resetear cámara al centro
	if camera:
		camera.reset_camera(self)
	
	# Actualizar HUD
	if hud:
		hud.textWin.remove_winner()
		hud.countdown.hide_countdown(true)
		if hud.disease_announcement:
			hud.disease_announcement.hide_announcement(true)
		hud.score_hud.update_scores(scores, target_wins)
	
	# Iniciar cuenta atrás de la ronda
	start_match_countdown()

func _cleanup_round() -> void:
	for p in active_player_nodes:
		if is_instance_valid(p):
			p.queue_free()
	active_player_nodes.clear()
	players.clear()
	
	if current_stage_node and is_instance_valid(current_stage_node):
		current_stage_node.queue_free()
		current_stage_node = null

func add_stage() -> void:
	if stage != null and stage != "":
		var stage_path: String = stage
		if not stage_path.begins_with("res://"):
			stage_path = "res://stages/" + stage
		if ResourceLoader.exists(stage_path):
			current_stage_node = load(stage_path).instantiate()
			add_child(current_stage_node)

func spawn_players() -> void:
	players.clear()
	active_player_nodes.clear()
	
	for info in PLAYER_DEFAULTS:
		var p: CharacterBody2D = Player.new()
		p._id = int(info["id"])
		p.nickname = str(info["nickname"])
		p.character = load(str(info["character"]))
		p.position = Vector2(float(info["x"]), float(info["y"]))
		p.can_move = false
		
		p.connect("on_died", Callable(self, "on_player_died"))
		p.connect("on_infected", Callable(self, "on_player_infected"))
		p.connect("on_cured", Callable(self, "on_player_cured"))
		
		add_child(p)
		players.append(p)
		active_player_nodes.append(p)

func start_match_countdown() -> void:
	if hud and hud.match_countdown:
		hud.match_countdown.connect("countdown_finished", Callable(self, "_on_match_countdown_finished"), CONNECT_ONE_SHOT)
		hud.match_countdown.start_countdown()
	else:
		_on_match_countdown_finished()

func _on_match_countdown_finished() -> void:
	is_round_active = true
	for player in players:
		if is_instance_valid(player):
			player.can_move = true
	set_random_disease()

func set_random_disease() -> void:
	if timerDisease:
		timerDisease.start()

func set_disease() -> void:
	if players.is_empty() or not is_round_active:
		return
	var disease = diseaseFactory.get_random_disease()
	var random_player = players[randi() % players.size()]
	if is_instance_valid(random_player):
		random_player.set_disease(disease)

func on_player_infected(player: CharacterBody2D, disease: Disease) -> void:
	if hud and hud.countdown:
		hud.countdown.start_countdown(disease, player)
	if hud and hud.disease_announcement:
		hud.disease_announcement.announce_disease(disease)

func on_player_cured(player: CharacterBody2D) -> void:
	if hud and hud.countdown:
		hud.countdown.stop_countdown(player)

func on_player_died(player: CharacterBody2D) -> void:
	players.erase(player)
	verify_players(player)

func verify_players(player: CharacterBody2D) -> void:
	if players.size() == 1:
		is_round_active = false
		var winner: CharacterBody2D = players[0]
		handle_round_winner(winner)
	elif players.size() == 0:
		is_round_active = false
		handle_round_draw()
	elif "status" in player and player.status != null and "isAfflicted" in player.status and player.status.isAfflicted and is_round_active:
		set_random_disease()

func handle_round_winner(winner: CharacterBody2D) -> void:
	if hud:
		if hud.countdown:
			hud.countdown.hide_countdown(true)
		if hud.match_countdown:
			hud.match_countdown.stop_countdown()
		if hud.disease_announcement:
			hud.disease_announcement.hide_announcement(true)
	
	if "status" in winner and winner.status != null and "isAfflicted" in winner.status and winner.status.isAfflicted:
		if winner.has_method("cured"):
			winner.cured()
	
	var winner_id: int = int(winner._id)
	scores[winner_id] = scores.get(winner_id, 0) + 1
	var current_wins: int = int(scores[winner_id])
	
	emit_signal("score_updated", scores)
	
	if hud and hud.score_hud:
		hud.score_hud.update_scores(scores, target_wins)
		hud.score_hud.highlight_winner(winner_id)
	
	if camera:
		camera.focus_on_winner(winner)
	
	if current_wins >= target_wins:
		# ¡Partida completada! Ganador definitivo
		is_match_over = true
		if hud and hud.textWin:
			hud.textWin.show_round_winner(winner.nickname, current_wins, target_wins, true)
		
		var winner_data: Dictionary = {
			"id": winner_id,
			"_id": winner_id,
			"nickname": winner.nickname,
			"character_path": "res://src/characters/" + winner.nickname + ".tscn"
		}
		
		emit_signal("round_won", winner, current_wins, target_wins)
		emit_signal("match_won", winner_data, scores, target_wins)
		
		if timerMatchEnd:
			timerMatchEnd.start()
	else:
		# Ronda ganada, continuar hacia la siguiente ronda
		if hud and hud.textWin:
			hud.textWin.show_round_winner(winner.nickname, current_wins, target_wins, false)
		
		emit_signal("round_won", winner, current_wins, target_wins)
		
		current_round += 1
		if timerRoundEnd:
			timerRoundEnd.start()

func handle_round_draw() -> void:
	if hud:
		if hud.countdown:
			hud.countdown.hide_countdown(true)
		if hud.match_countdown:
			hud.match_countdown.stop_countdown()
		if hud.disease_announcement:
			hud.disease_announcement.hide_announcement(true)
		if hud.textWin:
			hud.textWin.show_round_winner("EMPATE", -1, target_wins, false)
	
	if timerRoundEnd:
		timerRoundEnd.start()

func _on_match_end_timeout() -> void:
	# Este callback se dispara al terminar la partida si no fue capturado por Main
	# Main normalmente interceptará match_won para mostrar VictoryScene
	pass

func reset_match() -> void:
	reset_scores()
	start_round()

# Métodos heredados para compatibilidad
func game_over(winner: CharacterBody2D) -> void:
	handle_round_winner(winner)

func show_winner(winner: CharacterBody2D) -> void:
	handle_round_winner(winner)

func reload() -> void:
	reset_match()
