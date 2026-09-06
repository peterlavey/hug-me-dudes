class_name TextWin extends Control

var panel_container: PanelContainer
var header_label: Label
var winner_label: Label
var subtitle_label: Label
var particles_left: CPUParticles2D
var particles_right: CPUParticles2D

var _entry_tween: Tween
var _pulse_tween: Tween

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
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ensure_ui()
	remove_winner()

func _ensure_ui() -> void:
	if panel_container == null:
		config_ui()
		config_particles()

func config_ui() -> void:
	panel_container = PanelContainer.new()
	panel_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.09, 0.14, 0.92)
	style.border_color = Color(1.0, 0.82, 0.1, 1.0)
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.65)
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 4)
	style.content_margin_left = 36.0
	style.content_margin_right = 36.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	panel_container.add_theme_stylebox_override("panel", style)
	
	panel_container.layout_mode = 1
	panel_container.anchors_preset = Control.PRESET_CENTER_TOP
	panel_container.anchor_left = 0.5
	panel_container.anchor_right = 0.5
	panel_container.anchor_top = 0.0
	panel_container.anchor_bottom = 0.0
	panel_container.offset_left = 0.0
	panel_container.offset_right = 0.0
	panel_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel_container.grow_vertical = Control.GROW_DIRECTION_END
	panel_container.offset_top = 35.0
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	
	header_label = Label.new()
	header_label.text = "★ ¡VICTORIA! ★"
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_label.add_theme_font_size_override("font_size", 20)
	header_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3, 1.0))
	header_label.add_theme_color_override("font_outline_color", Color(0.15, 0.08, 0.0, 1.0))
	header_label.add_theme_constant_override("outline_size", 4)
	header_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	header_label.add_theme_constant_override("shadow_offset_x", 2)
	header_label.add_theme_constant_override("shadow_offset_y", 2)
	
	winner_label = Label.new()
	winner_label.text = ""
	winner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	winner_label.add_theme_font_size_override("font_size", 38)
	winner_label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.8, 1.0))
	winner_label.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.06, 1.0))
	winner_label.add_theme_constant_override("outline_size", 7)
	winner_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	winner_label.add_theme_constant_override("shadow_offset_x", 3)
	winner_label.add_theme_constant_override("shadow_offset_y", 3)
	
	subtitle_label = Label.new()
	subtitle_label.text = "¡ÚLTIMO SUPERVIVIENTE EN PIE!"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.86, 1.0, 0.9))
	subtitle_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.85))
	subtitle_label.add_theme_constant_override("outline_size", 3)
	subtitle_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	subtitle_label.add_theme_constant_override("shadow_offset_x", 1)
	subtitle_label.add_theme_constant_override("shadow_offset_y", 1)
	
	vbox.add_child(header_label)
	vbox.add_child(winner_label)
	vbox.add_child(subtitle_label)
	
	panel_container.add_child(vbox)
	add_child(panel_container)

func config_particles() -> void:
	particles_left = _create_confetti_emitter(Vector2(1.0, -0.6))
	particles_right = _create_confetti_emitter(Vector2(-1.0, -0.6))
	
	panel_container.add_child(particles_left)
	panel_container.add_child(particles_right)

func _create_confetti_emitter(direction: Vector2) -> CPUParticles2D:
	var emitter: CPUParticles2D = CPUParticles2D.new()
	emitter.emitting = false
	emitter.one_shot = true
	emitter.amount = 45
	emitter.lifetime = 2.2
	emitter.explosiveness = 0.88
	emitter.direction = direction
	emitter.spread = 50.0
	emitter.initial_velocity_min = 180.0
	emitter.initial_velocity_max = 350.0
	emitter.scale_amount_min = 3.5
	emitter.scale_amount_max = 6.5
	emitter.gravity = Vector2(0.0, 280.0)
	emitter.color = Color(1.0, 0.85, 0.2, 1.0)
	return emitter

func show_winner(winner: Variant) -> void:
	var winner_name: String = ""
	if winner is String:
		winner_name = winner
	elif winner != null and "nickname" in winner:
		winner_name = str(winner.nickname)
	else:
		winner_name = str(winner)
	show_round_winner(winner_name, -1, -1, false)

func show_round_winner(winner_name: String, current_wins: int = -1, target_wins: int = -1, is_match_winner: bool = false) -> void:
	_ensure_ui()
	
	if is_match_winner:
		header_label.text = "★ ¡VICTORIA DEFINITIVA! ★"
		winner_label.text = "¡" + winner_name.to_upper() + " GANA LA PARTIDA!"
		if target_wins > 0:
			subtitle_label.text = "¡PRIMER JUGADOR EN ALCANZAR " + str(target_wins) + " VICTORIAS!"
		else:
			subtitle_label.text = "¡CAMPEÓN DE LA PARTIDA!"
	elif current_wins > 0 and target_wins > 0:
		header_label.text = "★ ¡VICTORIA DE RONDA! ★"
		winner_label.text = "¡" + winner_name.to_upper() + " GANA LA RONDA!"
		subtitle_label.text = "VICTORIAS: %d / %d" % [current_wins, target_wins]
	else:
		header_label.text = "★ ¡VICTORIA! ★"
		winner_label.text = "¡" + winner_name.to_upper() + " ES EL GANADOR!"
		subtitle_label.text = "¡ÚLTIMO SUPERVIVIENTE EN PIE!"
	
	panel_container.visible = true
	panel_container.modulate = Color(1.0, 1.0, 1.0, 1.0)
	panel_container.scale = Vector2(1.0, 1.0)
	
	# Asegurar tamaño y pivote centrado para las animaciones y partículas
	panel_container.reset_size()
	var container_size: Vector2 = panel_container.get_combined_minimum_size()
	if panel_container.size.x > container_size.x:
		container_size = panel_container.size
	panel_container.pivot_offset = Vector2(container_size.x / 2.0, container_size.y / 2.0)
	
	particles_left.position = Vector2(0.0, container_size.y / 2.0)
	particles_right.position = Vector2(container_size.x, container_size.y / 2.0)
	
	if is_inside_tree():
		panel_container.modulate = Color(1.0, 1.0, 1.0, 0.0)
		panel_container.scale = Vector2(0.3, 0.3)
		
		if _entry_tween and _entry_tween.is_valid():
			_entry_tween.kill()
		if _pulse_tween and _pulse_tween.is_valid():
			_pulse_tween.kill()
		
		_entry_tween = create_tween()
		_entry_tween.set_trans(Tween.TRANS_BACK)
		_entry_tween.set_ease(Tween.EASE_OUT)
		_entry_tween.parallel().tween_property(panel_container, "scale", Vector2(1.0, 1.0), 0.6)
		_entry_tween.parallel().tween_property(panel_container, "modulate:a", 1.0, 0.4)
		
		particles_left.restart()
		particles_right.restart()
		
		_entry_tween.chain().tween_callback(Callable(self, "_start_pulse_animation"))

func _start_pulse_animation() -> void:
	if not is_inside_tree():
		return
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.set_trans(Tween.TRANS_SINE)
	_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(winner_label, "scale", Vector2(1.04, 1.04), 0.6)
	_pulse_tween.tween_property(winner_label, "scale", Vector2(1.0, 1.0), 0.6)

func remove_winner() -> void:
	if _entry_tween and _entry_tween.is_valid():
		_entry_tween.kill()
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	
	if panel_container:
		panel_container.visible = false
	if particles_left:
		particles_left.emitting = false
	if particles_right:
		particles_right.emitting = false