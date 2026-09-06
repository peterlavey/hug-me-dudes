class_name VictoryScene extends Control

signal play_again_requested
signal menu_requested

var panel_card: PanelContainer
var header_label: Label
var winner_name_label: Label
var winner_subtitle_label: Label
var character_container: Control
var scoreboard_container: VBoxContainer
var play_again_button: Button
var menu_button: Button
var particles_left: CPUParticles2D
var particles_right: CPUParticles2D
var particles_top: CPUParticles2D

var _winner_data: Dictionary = {}
var _scores: Dictionary = {}
var _target_wins: int = 3
var _character_node: Node = null

const PLAYER_COLORS: Dictionary = {
	1: Color(0.25, 0.75, 1.0, 1.0), # Peter
	2: Color(1.0, 0.65, 0.2, 1.0),  # Kenny
	3: Color(0.35, 0.9, 0.45, 1.0), # Bestian
	4: Color(0.95, 0.35, 0.85, 1.0) # Wyrm
}

const PLAYER_NAMES: Dictionary = {
	1: "Peter",
	2: "Kenny",
	3: "Bestian",
	4: "Wyrm"
}

func _init() -> void:
	_ensure_ui()

func _ready() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_right = 0.0
	offset_bottom = 0.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	_ensure_ui()
	_play_entrance_animation()
	
	if play_again_button:
		play_again_button.grab_focus()

func setup(winner_data: Dictionary, scores: Dictionary, target_wins: int = 3) -> void:
	_ensure_ui()
	_winner_data = winner_data
	_scores = scores
	_target_wins = target_wins
	
	_update_ui_content()

func _ensure_ui() -> void:
	if panel_card == null:
		config_ui()
		config_particles()

func config_ui() -> void:
	# Fondo oscurecido con viñeta
	var bg_rect: ColorRect = ColorRect.new()
	bg_rect.anchors_preset = Control.PRESET_FULL_RECT
	bg_rect.anchor_right = 1.0
	bg_rect.anchor_bottom = 1.0
	bg_rect.color = Color(0.04, 0.05, 0.09, 0.94)
	bg_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg_rect)
	
	# Contenedor central principal
	panel_card = PanelContainer.new()
	panel_card.layout_mode = 1
	panel_card.anchors_preset = Control.PRESET_CENTER
	panel_card.anchor_left = 0.5
	panel_card.anchor_right = 0.5
	panel_card.anchor_top = 0.5
	panel_card.anchor_bottom = 0.5
	panel_card.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel_card.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var card_style: StyleBoxFlat = StyleBoxFlat.new()
	card_style.bg_color = Color(0.08, 0.1, 0.16, 0.96)
	card_style.border_color = Color(1.0, 0.82, 0.15, 1.0)
	card_style.set_border_width_all(3)
	card_style.set_corner_radius_all(16)
	card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.8)
	card_style.shadow_size = 18
	card_style.shadow_offset = Vector2(0, 6)
	card_style.content_margin_left = 32.0
	card_style.content_margin_right = 32.0
	card_style.content_margin_top = 20.0
	card_style.content_margin_bottom = 20.0
	panel_card.add_theme_stylebox_override("panel", card_style)
	
	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_theme_constant_override("separation", 10)
	
	# Cabecera de victoria
	header_label = Label.new()
	header_label.text = "★ ¡VICTORIA DE LA PARTIDA! ★"
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_label.add_theme_font_size_override("font_size", 22)
	header_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25, 1.0))
	header_label.add_theme_color_override("font_outline_color", Color(0.15, 0.08, 0.0, 1.0))
	header_label.add_theme_constant_override("outline_size", 4)
	header_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	header_label.add_theme_constant_override("shadow_offset_x", 2)
	header_label.add_theme_constant_override("shadow_offset_y", 2)
	main_vbox.add_child(header_label)
	
	# Contenedor de visualización del personaje ganador
	character_container = Control.new()
	character_container.custom_minimum_size = Vector2(80, 80)
	character_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	main_vbox.add_child(character_container)
	
	# Nombre del ganador
	winner_name_label = Label.new()
	winner_name_label.text = "¡JUGADOR ES EL CAMPEÓN!"
	winner_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	winner_name_label.add_theme_font_size_override("font_size", 34)
	winner_name_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.85, 1.0))
	winner_name_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.05, 1.0))
	winner_name_label.add_theme_constant_override("outline_size", 6)
	winner_name_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	winner_name_label.add_theme_constant_override("shadow_offset_x", 3)
	winner_name_label.add_theme_constant_override("shadow_offset_y", 3)
	main_vbox.add_child(winner_name_label)
	
	# Subtítulo descriptivo
	winner_subtitle_label = Label.new()
	winner_subtitle_label.text = "¡Primer jugador en alcanzar 3 victorias!"
	winner_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	winner_subtitle_label.add_theme_font_size_override("font_size", 14)
	winner_subtitle_label.add_theme_color_override("font_color", Color(0.75, 0.88, 1.0, 0.9))
	winner_subtitle_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.8))
	winner_subtitle_label.add_theme_constant_override("outline_size", 2)
	main_vbox.add_child(winner_subtitle_label)
	
	# Separador
	var separator: HSeparator = HSeparator.new()
	separator.add_theme_constant_override("separation", 12)
	main_vbox.add_child(separator)
	
	# Tabla de clasificación (Scoreboard)
	var scores_title: Label = Label.new()
	scores_title.text = "TABLA DE VICTORIAS"
	scores_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scores_title.add_theme_font_size_override("font_size", 13)
	scores_title.add_theme_color_override("font_color", Color(0.8, 0.85, 0.95, 0.8))
	main_vbox.add_child(scores_title)
	
	scoreboard_container = VBoxContainer.new()
	scoreboard_container.alignment = BoxContainer.ALIGNMENT_CENTER
	scoreboard_container.add_theme_constant_override("separation", 4)
	main_vbox.add_child(scoreboard_container)
	
	# Separador inferior
	var separator2: HSeparator = HSeparator.new()
	separator2.add_theme_constant_override("separation", 14)
	main_vbox.add_child(separator2)
	
	# Botones de acción
	var button_hbox: HBoxContainer = HBoxContainer.new()
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_hbox.add_theme_constant_override("separation", 16)
	
	play_again_button = _create_button("🎮 JUGAR DE NUEVO", Color(0.15, 0.65, 0.35, 1.0))
	play_again_button.pressed.connect(_on_play_again_pressed)
	button_hbox.add_child(play_again_button)
	
	menu_button = _create_button("🏠 MENÚ PRINCIPAL", Color(0.35, 0.45, 0.6, 1.0))
	menu_button.pressed.connect(_on_menu_pressed)
	button_hbox.add_child(menu_button)
	
	main_vbox.add_child(button_hbox)
	panel_card.add_child(main_vbox)
	add_child(panel_card)

func _create_button(text: String, accent_color: Color) -> Button:
	var btn: Button = Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(160, 36)
	btn.add_theme_font_size_override("font_size", 14)
	
	var normal_style: StyleBoxFlat = StyleBoxFlat.new()
	normal_style.bg_color = Color(0.12, 0.15, 0.22, 0.95)
	normal_style.border_color = accent_color
	normal_style.set_border_width_all(2)
	normal_style.set_corner_radius_all(8)
	normal_style.content_margin_left = 12.0
	normal_style.content_margin_right = 12.0
	normal_style.content_margin_top = 6.0
	normal_style.content_margin_bottom = 6.0
	btn.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style: StyleBoxFlat = normal_style.duplicate()
	hover_style.bg_color = accent_color.darkened(0.4)
	hover_style.border_color = Color(1.0, 1.0, 1.0, 1.0)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	var focus_style: StyleBoxFlat = normal_style.duplicate()
	focus_style.border_color = Color(1.0, 0.9, 0.2, 1.0)
	focus_style.set_border_width_all(3)
	btn.add_theme_stylebox_override("focus", focus_style)
	
	return btn

func config_particles() -> void:
	particles_left = _create_confetti_emitter(Vector2(1.0, -0.7))
	particles_right = _create_confetti_emitter(Vector2(-1.0, -0.7))
	particles_top = _create_confetti_emitter(Vector2(0.0, 1.0))
	particles_top.spread = 80.0
	
	add_child(particles_left)
	add_child(particles_right)
	add_child(particles_top)

func _create_confetti_emitter(direction: Vector2) -> CPUParticles2D:
	var emitter: CPUParticles2D = CPUParticles2D.new()
	emitter.emitting = false
	emitter.one_shot = false
	emitter.amount = 40
	emitter.lifetime = 2.5
	emitter.explosiveness = 0.6
	emitter.direction = direction
	emitter.spread = 45.0
	emitter.initial_velocity_min = 160.0
	emitter.initial_velocity_max = 320.0
	emitter.scale_amount_min = 3.5
	emitter.scale_amount_max = 7.0
	emitter.gravity = Vector2(0.0, 220.0)
	emitter.color = Color(1.0, 0.85, 0.2, 1.0)
	return emitter

func _update_ui_content() -> void:
	var winner_id: int = int(_winner_data.get("id", _winner_data.get("_id", 1)))
	var winner_name: String = str(_winner_data.get("nickname", PLAYER_NAMES.get(winner_id, "Jugador " + str(winner_id))))
	
	winner_name_label.text = "¡" + winner_name.to_upper() + " ES EL CAMPEÓN!"
	var winner_color: Color = PLAYER_COLORS.get(winner_id, Color(1.0, 0.85, 0.2, 1.0))
	winner_name_label.add_theme_color_override("font_color", winner_color)
	
	winner_subtitle_label.text = "¡Primer jugador en alcanzar %d victorias en la partida!" % _target_wins
	
	# Instanciar el personaje animado en el centro si existe
	_setup_winner_character(winner_id)
	
	# Poblar scoreboard clasificado de mayor a menor victorias
	_populate_scoreboard(winner_id)

func _setup_winner_character(winner_id: int) -> void:
	if _character_node and is_instance_valid(_character_node):
		_character_node.queue_free()
	
	var char_scene_path: String = ""
	if _winner_data.has("character_path") and _winner_data["character_path"] != "":
		char_scene_path = str(_winner_data["character_path"])
	else:
		var name_key: String = PLAYER_NAMES.get(winner_id, "Peter")
		char_scene_path = "res://src/characters/" + name_key + ".tscn"
	
	if ResourceLoader.exists(char_scene_path):
		var packed: PackedScene = load(char_scene_path)
		if packed:
			_character_node = packed.instantiate()
			character_container.add_child(_character_node)
			if _character_node is AnimatedSprite2D:
				var anim_sprite: AnimatedSprite2D = _character_node as AnimatedSprite2D
				anim_sprite.position = Vector2(character_container.custom_minimum_size.x / 2.0, character_container.custom_minimum_size.y / 2.0)
				anim_sprite.scale = Vector2(1.8, 1.8)
				if anim_sprite.sprite_frames and anim_sprite.sprite_frames.has_animation("Idle"):
					anim_sprite.play("Idle")

func _populate_scoreboard(winner_id: int) -> void:
	for child in scoreboard_container.get_children():
		child.queue_free()
	
	# Recopilar todos los IDs de jugadores conocidos
	var all_ids: Array = [1, 2, 3, 4]
	for k in _scores.keys():
		var int_k: int = int(k)
		if not all_ids.has(int_k):
			all_ids.append(int_k)
	
	# Ordenar por puntuación descendente
	all_ids.sort_custom(func(a: int, b: int) -> bool:
		var score_a: int = int(_scores.get(a, 0))
		var score_b: int = int(_scores.get(b, 0))
		if score_a != score_b:
			return score_a > score_b
		return a == winner_id
	)
	
	var rank: int = 1
	for p_id in all_ids:
		var p_name: String = PLAYER_NAMES.get(p_id, "Jugador " + str(p_id))
		var score: int = int(_scores.get(p_id, 0))
		var p_color: Color = PLAYER_COLORS.get(p_id, Color(0.8, 0.8, 0.8, 1.0))
		var is_champ: bool = (p_id == winner_id)
		
		var row: HBoxContainer = HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 12)
		
		var rank_lbl: Label = Label.new()
		rank_lbl.custom_minimum_size = Vector2(28, 0)
		rank_lbl.text = ("👑 " if is_champ else str(rank) + "º ")
		rank_lbl.add_theme_font_size_override("font_size", 13)
		rank_lbl.add_theme_color_override("font_color", (Color(1.0, 0.85, 0.2, 1.0) if is_champ else Color(0.7, 0.75, 0.85, 0.9)))
		
		var name_lbl: Label = Label.new()
		name_lbl.custom_minimum_size = Vector2(110, 0)
		name_lbl.text = p_name
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", p_color)
		
		var score_lbl: Label = Label.new()
		score_lbl.custom_minimum_size = Vector2(90, 0)
		score_lbl.text = "%d / %d victorias" % [score, _target_wins]
		score_lbl.add_theme_font_size_override("font_size", 13)
		score_lbl.add_theme_color_override("font_color", (Color(1.0, 0.95, 0.7, 1.0) if is_champ else Color(0.75, 0.8, 0.9, 0.9)))
		
		row.add_child(rank_lbl)
		row.add_child(name_lbl)
		row.add_child(score_lbl)
		
		scoreboard_container.add_child(row)
		rank += 1

func _play_entrance_animation() -> void:
	if not is_inside_tree() or panel_card == null:
		return
	
	panel_card.reset_size()
	var container_size: Vector2 = panel_card.get_combined_minimum_size()
	panel_card.pivot_offset = Vector2(container_size.x / 2.0, container_size.y / 2.0)
	
	panel_card.modulate = Color(1.0, 1.0, 1.0, 0.0)
	panel_card.scale = Vector2(0.4, 0.4)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(panel_card, "scale", Vector2(1.0, 1.0), 0.55)
	tween.parallel().tween_property(panel_card, "modulate:a", 1.0, 0.35)
	
	# Iniciar partículas
	var view_size: Vector2 = get_viewport_rect().size
	if particles_left:
		particles_left.position = Vector2(40.0, view_size.y * 0.75)
		particles_left.emitting = true
	if particles_right:
		particles_right.position = Vector2(view_size.x - 40.0, view_size.y * 0.75)
		particles_right.emitting = true
	if particles_top:
		particles_top.position = Vector2(view_size.x / 2.0, 10.0)
		particles_top.emitting = true

func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_kick_1") or event.is_action_pressed("ui_kick_2") or event.is_action_pressed("ui_kick_3") or event.is_action_pressed("ui_kick_4"):
		# Si está enfocado algún botón, se procesa automáticamente; si no, jugar de nuevo
		if get_viewport() and get_viewport().gui_get_focus_owner() == null:
			_on_play_again_pressed()
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_on_menu_pressed()
		get_viewport().set_input_as_handled()

func _on_play_again_pressed() -> void:
	emit_signal("play_again_requested")

func _on_menu_pressed() -> void:
	emit_signal("menu_requested")
