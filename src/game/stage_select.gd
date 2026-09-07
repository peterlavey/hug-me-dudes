class_name StageSelect extends Control

## Señales
signal on_selected_stage(stage_path: String)
signal stage_selected(stage_path: String)
signal back_requested()

## Variables de Estado y Configuración
var stages: Array[PackedScene] = []
var stage_list: Array[String] = []
var stage_index: int = 0
var current_stage_instance: Node = null
var is_selected: bool = false
var _audio_cooldown: float = 0.0
var _nav_debounce_timer: float = 0.0
const NAV_DEBOUNCE_TIME: float = 0.18

## Metadatos informativos de escenarios
const STAGE_METADATA: Dictionary = {
	"Ship.tscn": {
		"title": "EL BARCO PIRATA",
		"subtitle": "Cubierta flotante y fosas de espinas",
		"description": "Plataformas de madera sobre el abismo. Cuidado con las caídas directas a los picos inferiores.",
		"color": Color(0.95, 0.65, 0.25, 1.0)
	},
	"Towers.tscn": {
		"title": "LAS TORRES GEMELAS",
		"subtitle": "Estructuras verticales y saltos al límite",
		"description": "Combate en múltiples alturas. Ideal para empujar rivales desde lo alto hacia el vacío.",
		"color": Color(0.35, 0.85, 0.95, 1.0)
	},
	"Stage.tscn": {
		"title": "ARENA CLÁSICA",
		"subtitle": "Campo de batalla equilibrado",
		"description": "Espacio abierto para confrontación directa y contagio rápido cuerpo a cuerpo.",
		"color": Color(0.45, 0.95, 0.55, 1.0)
	}
}

## Referencias UI
var background_sprite: TextureRect
var background_overlay: ColorRect
var particles: CPUParticles2D
var main_container: VBoxContainer
var header_title: Label
var header_subtitle: Label
var card_panel: PanelContainer
var viewport_container: SubViewportContainer
var sub_viewport: SubViewport
var preview_camera: Camera2D
var stage_title_label: Label
var stage_subtitle_label: Label
var stage_desc_label: Label
var stage_counter_label: Label
var dots_container: HBoxContainer
var btn_left: Button
var btn_right: Button
var btn_select: Button
var btn_back: Button
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer

var folder_manager = load("res://src/utils/folderManager.gd").new()
var _is_initialized: bool = false

func _init() -> void:
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_right = 0.0
	offset_bottom = 0.0
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH
	ensure_initialized()

func _ready() -> void:
	ensure_initialized()

func ensure_initialized() -> void:
	if _is_initialized:
		return
	_is_initialized = true
	_build_ui()
	_config_audio()
	_load_stages()
	_update_stage_display(false)

func _process(delta: float) -> void:
	if _audio_cooldown > 0.0:
		_audio_cooldown -= delta
	if _nav_debounce_timer > 0.0:
		_nav_debounce_timer -= delta

func _build_ui() -> void:
	# 1. Fondo con textura base start.jpg
	background_sprite = TextureRect.new()
	background_sprite.anchors_preset = Control.PRESET_FULL_RECT
	background_sprite.anchor_right = 1.0
	background_sprite.anchor_bottom = 1.0
	background_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if ResourceLoader.exists("res://sprites/menu/start.jpg"):
		background_sprite.texture = load("res://sprites/menu/start.jpg")
	add_child(background_sprite)
	
	# 2. Overlay oscuro con tinte azulado/morado para contraste
	background_overlay = ColorRect.new()
	background_overlay.anchors_preset = Control.PRESET_FULL_RECT
	background_overlay.anchor_right = 1.0
	background_overlay.anchor_bottom = 1.0
	background_overlay.color = Color(0.05, 0.07, 0.12, 0.88)
	background_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background_overlay)
	
	# 3. Partículas de ambiente
	_create_particles()
	
	# 4. Contenedor Principal
	main_container = VBoxContainer.new()
	main_container.anchors_preset = Control.PRESET_FULL_RECT
	main_container.anchor_right = 1.0
	main_container.anchor_bottom = 1.0
	main_container.offset_left = 30.0
	main_container.offset_top = 20.0
	main_container.offset_right = -30.0
	main_container.offset_bottom = -20.0
	main_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	main_container.grow_vertical = Control.GROW_DIRECTION_BOTH
	main_container.add_theme_constant_override("separation", 12)
	main_container.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(main_container)
	
	# 5. Header (Título y Subtítulo)
	var header_box: VBoxContainer = VBoxContainer.new()
	header_box.alignment = BoxContainer.ALIGNMENT_CENTER
	header_box.add_theme_constant_override("separation", 2)
	
	header_title = Label.new()
	header_title.text = "SELECCIÓN DE ESCENARIO"
	header_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_title.add_theme_font_size_override("font_size", 24)
	header_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25, 1.0))
	header_title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	header_title.add_theme_constant_override("shadow_offset_x", 2)
	header_title.add_theme_constant_override("shadow_offset_y", 2)
	header_box.add_child(header_title)
	
	header_subtitle = Label.new()
	header_subtitle.text = "Elige el campo de batalla para el combate"
	header_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_subtitle.add_theme_font_size_override("font_size", 13)
	header_subtitle.add_theme_color_override("font_color", Color(0.75, 0.82, 0.9, 0.9))
	header_box.add_child(header_subtitle)
	
	main_container.add_child(header_box)
	
	# 6. Fila Central: [Botón Izquierda] + [Tarjeta con Preview de Stage] + [Botón Derecha]
	var center_row: HBoxContainer = HBoxContainer.new()
	center_row.alignment = BoxContainer.ALIGNMENT_CENTER
	center_row.add_theme_constant_override("separation", 18)
	
	btn_left = _create_arrow_button("◀", Callable(self, "prev_stage"))
	center_row.add_child(btn_left)
	
	# Tarjeta central con panel estilizado
	card_panel = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(560, 340)
	
	var card_style: StyleBoxFlat = StyleBoxFlat.new()
	card_style.bg_color = Color(0.07, 0.09, 0.15, 0.95)
	card_style.border_color = Color(1.0, 0.82, 0.25, 0.9)
	card_style.set_border_width_all(3)
	card_style.set_corner_radius_all(14)
	card_style.shadow_color = Color(0.0, 0.0, 0.0, 0.8)
	card_style.shadow_size = 14
	card_style.shadow_offset = Vector2(0, 5)
	card_style.content_margin_left = 16.0
	card_style.content_margin_right = 16.0
	card_style.content_margin_top = 12.0
	card_style.content_margin_bottom = 12.0
	card_panel.add_theme_stylebox_override("panel", card_style)
	
	var card_vbox: VBoxContainer = VBoxContainer.new()
	card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card_vbox.add_theme_constant_override("separation", 8)
	
	# Barra de título del stage dentro de la tarjeta
	var stage_header_hbox: HBoxContainer = HBoxContainer.new()
	stage_header_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	stage_title_label = Label.new()
	stage_title_label.text = "ESCENARIO"
	stage_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_title_label.add_theme_font_size_override("font_size", 18)
	stage_title_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4, 1.0))
	stage_header_hbox.add_child(stage_title_label)
	
	stage_counter_label = Label.new()
	stage_counter_label.text = "1 / 3"
	stage_counter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stage_counter_label.add_theme_font_size_override("font_size", 14)
	stage_counter_label.add_theme_color_override("font_color", Color(0.65, 0.75, 0.85, 0.8))
	stage_header_hbox.add_child(stage_counter_label)
	
	card_vbox.add_child(stage_header_hbox)
	
	# Marco de visualización (SubViewport)
	var viewport_frame: PanelContainer = PanelContainer.new()
	viewport_frame.custom_minimum_size = Vector2(528, 220)
	viewport_frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var vp_frame_style: StyleBoxFlat = StyleBoxFlat.new()
	vp_frame_style.bg_color = Color(0.02, 0.03, 0.06, 1.0)
	vp_frame_style.border_color = Color(0.3, 0.4, 0.55, 0.8)
	vp_frame_style.set_border_width_all(2)
	vp_frame_style.set_corner_radius_all(8)
	vp_frame_style.content_margin_left = 2.0
	vp_frame_style.content_margin_right = 2.0
	vp_frame_style.content_margin_top = 2.0
	vp_frame_style.content_margin_bottom = 2.0
	viewport_frame.add_theme_stylebox_override("panel", vp_frame_style)
	
	viewport_container = SubViewportContainer.new()
	viewport_container.custom_minimum_size = Vector2(524, 216)
	viewport_container.stretch = true
	viewport_container.mouse_filter = Control.MOUSE_FILTER_PASS
	
	sub_viewport = SubViewport.new()
	sub_viewport.size = Vector2i(1067, 600)
	sub_viewport.handle_input_locally = false
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	
	preview_camera = Camera2D.new()
	preview_camera.position = Vector2(533.5, 300.0)
	preview_camera.zoom = Vector2(1.0, 1.0)
	sub_viewport.add_child(preview_camera)
	
	viewport_container.add_child(sub_viewport)
	viewport_frame.add_child(viewport_container)
	card_vbox.add_child(viewport_frame)
	
	# Descripción del stage
	stage_subtitle_label = Label.new()
	stage_subtitle_label.text = "Descripción del mapa"
	stage_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_subtitle_label.add_theme_font_size_override("font_size", 13)
	stage_subtitle_label.add_theme_color_override("font_color", Color(0.85, 0.88, 0.95, 0.95))
	card_vbox.add_child(stage_subtitle_label)
	
	stage_desc_label = Label.new()
	stage_desc_label.text = "Detalles tácticos y características"
	stage_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stage_desc_label.add_theme_font_size_override("font_size", 11)
	stage_desc_label.add_theme_color_override("font_color", Color(0.65, 0.72, 0.82, 0.85))
	card_vbox.add_child(stage_desc_label)
	
	# Indicadores de puntos / dots
	dots_container = HBoxContainer.new()
	dots_container.alignment = BoxContainer.ALIGNMENT_CENTER
	dots_container.add_theme_constant_override("separation", 8)
	card_vbox.add_child(dots_container)
	
	card_panel.add_child(card_vbox)
	center_row.add_child(card_panel)
	
	btn_right = _create_arrow_button("▶", Callable(self, "next_stage"))
	center_row.add_child(btn_right)
	
	main_container.add_child(center_row)
	
	# 7. Botones de Acción Inferiores y Atajos
	var bottom_actions_hbox: HBoxContainer = HBoxContainer.new()
	bottom_actions_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom_actions_hbox.add_theme_constant_override("separation", 24)
	
	btn_back = _create_action_button("◀ VOLVER AL MENÚ", Color(0.7, 0.25, 0.25, 1.0), Callable(self, "_on_back_pressed"))
	bottom_actions_hbox.add_child(btn_back)
	
	btn_select = _create_action_button("▶ INICIAR PARTIDA", Color(0.2, 0.75, 0.4, 1.0), Callable(self, "select_current_stage"))
	bottom_actions_hbox.add_child(btn_select)
	
	main_container.add_child(bottom_actions_hbox)
	
	# 8. Barra de ayuda de controles
	var controls_legend: Label = Label.new()
	controls_legend.text = "[A / D] o [← / →] Cambiar Escenario   •   [ENTER / ESPACIO] Seleccionar   •   [ESC] Volver"
	controls_legend.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_legend.add_theme_font_size_override("font_size", 11)
	controls_legend.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75, 0.7))
	main_container.add_child(controls_legend)

func _create_arrow_button(arrow_text: String, callback: Callable) -> Button:
	var btn: Button = Button.new()
	btn.text = arrow_text
	btn.custom_minimum_size = Vector2(50, 60)
	btn.add_theme_font_size_override("font_size", 22)
	btn.focus_mode = Control.FOCUS_NONE
	
	var style_normal: StyleBoxFlat = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.12, 0.16, 0.25, 0.85)
	style_normal.border_color = Color(0.4, 0.55, 0.8, 0.8)
	style_normal.set_border_width_all(2)
	style_normal.set_corner_radius_all(10)
	
	var style_hover: StyleBoxFlat = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.2, 0.3, 0.48, 0.95)
	style_hover.border_color = Color(1.0, 0.85, 0.3, 1.0)
	style_hover.set_border_width_all(2)
	style_hover.set_corner_radius_all(10)
	
	var style_pressed: StyleBoxFlat = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.1, 0.2, 0.35, 1.0)
	style_pressed.border_color = Color(0.9, 0.7, 0.2, 1.0)
	style_pressed.set_border_width_all(2)
	style_pressed.set_corner_radius_all(10)
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	btn.pressed.connect(callback)
	return btn

func _create_action_button(label_text: String, accent_color: Color, callback: Callable) -> Button:
	var btn: Button = Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(190, 42)
	btn.add_theme_font_size_override("font_size", 14)
	btn.focus_mode = Control.FOCUS_NONE
	
	var style_normal: StyleBoxFlat = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.1, 0.13, 0.2, 0.9)
	style_normal.border_color = accent_color
	style_normal.set_border_width_all(2)
	style_normal.set_corner_radius_all(8)
	style_normal.content_margin_left = 16.0
	style_normal.content_margin_right = 16.0
	
	var style_hover: StyleBoxFlat = StyleBoxFlat.new()
	style_hover.bg_color = accent_color * Color(0.3, 0.3, 0.3, 1.0) + Color(0.1, 0.1, 0.1, 0.9)
	style_hover.border_color = Color(1.0, 0.95, 0.6, 1.0)
	style_hover.set_border_width_all(2)
	style_hover.set_corner_radius_all(8)
	style_hover.content_margin_left = 16.0
	style_hover.content_margin_right = 16.0
	
	var style_focus: StyleBoxFlat = StyleBoxFlat.new()
	style_focus.bg_color = accent_color * Color(0.4, 0.4, 0.4, 1.0) + Color(0.15, 0.15, 0.15, 0.9)
	style_focus.border_color = Color(1.0, 0.95, 0.7, 1.0)
	style_focus.set_border_width_all(3)
	style_focus.set_corner_radius_all(8)
	style_focus.content_margin_left = 16.0
	style_focus.content_margin_right = 16.0
	
	btn.add_theme_stylebox_override("normal", style_normal)
	btn.add_theme_stylebox_override("hover", style_hover)
	btn.add_theme_stylebox_override("focus", style_focus)
	btn.pressed.connect(callback)
	return btn

func _create_particles() -> void:
	particles = CPUParticles2D.new()
	particles.position = Vector2(533, 300)
	particles.amount = 35
	particles.lifetime = 4.0
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(550, 320)
	particles.gravity = Vector2(0, -10)
	particles.scale_amount_min = 2.0
	particles.scale_amount_max = 4.5
	particles.color = Color(1.0, 0.85, 0.4, 0.25)
	add_child(particles)

func _config_audio() -> void:
	# Música de menú
	music_player = AudioStreamPlayer.new()
	if ResourceLoader.exists("res://sounds/menu/song.ogg"):
		music_player.stream = load("res://sounds/menu/song.ogg")
	add_child(music_player)
	if is_inside_tree() and music_player.stream:
		music_player.play()
	
	# SFX de navegación
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

func _play_sfx_feedback(is_confirm: bool = false) -> void:
	if not is_inside_tree() or sfx_player == null:
		return
	# Generación de tonos rápidos de interfaz mediante audio sintético procedural
	var sample_rate: float = 22050.0
	var duration: float = 0.08 if not is_confirm else 0.18
	var num_samples: int = int(sample_rate * duration)
	var freq: float = 660.0 if not is_confirm else 880.0
	var byte_array: PackedByteArray = PackedByteArray()
	byte_array.resize(num_samples)
	
	for i in range(num_samples):
		var t: float = float(i) / sample_rate
		var envelope: float = 1.0 - (float(i) / float(num_samples))
		var value: float = sin(t * freq * TAU) * envelope * 0.35
		var byte_val: int = clampi(int((value + 1.0) * 127.5), 0, 255)
		byte_array.set(i, byte_val)
	
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = int(sample_rate)
	stream.stereo = false
	stream.data = byte_array
	sfx_player.stream = stream
	sfx_player.play()

func _load_stages() -> void:
	stages.clear()
	stage_list.clear()
	
	var discovered_files: Array = folder_manager.get_directory_list("res://stages", "tscn")
	discovered_files.sort()
	
	for file_name in discovered_files:
		var full_path: String = "res://stages/" + file_name
		if ResourceLoader.exists(full_path):
			var packed_scene: PackedScene = load(full_path)
			if packed_scene:
				stages.append(packed_scene)
				stage_list.append(file_name)
	
	# Fallback de seguridad si no se detectaron archivos
	if stages.is_empty():
		for default_stage in ["Ship.tscn", "Towers.tscn", "Stage.tscn"]:
			var p: String = "res://stages/" + default_stage
			if ResourceLoader.exists(p):
				var sc: PackedScene = load(p)
				if sc:
					stages.append(sc)
					stage_list.append(default_stage)
	
	stage_index = clampi(stage_index, 0, maxi(0, stages.size() - 1))
	_rebuild_dots()

func _rebuild_dots() -> void:
	if not dots_container:
		return
	
	for child in dots_container.get_children():
		child.queue_free()
	
	for i in range(stages.size()):
		var dot_btn: Button = Button.new()
		dot_btn.custom_minimum_size = Vector2(16, 16)
		dot_btn.focus_mode = Control.FOCUS_NONE
		var dot_idx: int = i
		dot_btn.pressed.connect(func(): set_stage_index(dot_idx))
		dots_container.add_child(dot_btn)
	
	_update_dots_style()

func _update_dots_style() -> void:
	if not dots_container:
		return
	var children: Array[Node] = dots_container.get_children()
	for i in range(children.size()):
		var dot_btn: Button = children[i] as Button
		if not dot_btn:
			continue
		
		var is_current: bool = (i == stage_index)
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.set_corner_radius_all(8)
		if is_current:
			style.bg_color = Color(1.0, 0.85, 0.25, 1.0)
			style.border_color = Color(1.0, 1.0, 1.0, 0.9)
			style.set_border_width_all(2)
			dot_btn.custom_minimum_size = Vector2(28, 14)
		else:
			style.bg_color = Color(0.25, 0.32, 0.45, 0.6)
			style.border_color = Color(0.4, 0.5, 0.65, 0.4)
			style.set_border_width_all(1)
			dot_btn.custom_minimum_size = Vector2(14, 14)
		
		dot_btn.add_theme_stylebox_override("normal", style)
		dot_btn.add_theme_stylebox_override("hover", style)
		dot_btn.add_theme_stylebox_override("pressed", style)

func _update_stage_display(animate: bool = true) -> void:
	if stages.is_empty():
		return
	
	stage_index = clampi(stage_index, 0, stages.size() - 1)
	var current_file: String = stage_list[stage_index]
	
	# Metadata
	var meta: Dictionary = STAGE_METADATA.get(current_file, {
		"title": current_file.get_basename().to_upper(),
		"subtitle": "Escenario de Combate",
		"description": "Arena para enfrentamiento multijugador.",
		"color": Color(0.4, 0.8, 1.0, 1.0)
	})
	
	if stage_title_label:
		stage_title_label.text = meta.get("title", current_file.get_basename().to_upper())
		stage_title_label.add_theme_color_override("font_color", meta.get("color", Color(1.0, 0.9, 0.4, 1.0)))
	
	if stage_subtitle_label:
		stage_subtitle_label.text = meta.get("subtitle", "")
	
	if stage_desc_label:
		stage_desc_label.text = meta.get("description", "")
	
	if stage_counter_label:
		stage_counter_label.text = "%d / %d" % [stage_index + 1, stages.size()]
	
	_update_dots_style()
	
	# Actualizar instancia en SubViewport
	if current_stage_instance and is_instance_valid(current_stage_instance):
		current_stage_instance.queue_free()
		current_stage_instance = null
	
	var stage_scene: PackedScene = stages[stage_index]
	if stage_scene and sub_viewport:
		current_stage_instance = stage_scene.instantiate()
		sub_viewport.add_child(current_stage_instance)
	
	if animate and viewport_container and is_inside_tree():
		viewport_container.modulate = Color(1.2, 1.2, 1.2, 0.6)
		var tween: Tween = create_tween()
		if tween:
			tween.tween_property(viewport_container, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func next_stage() -> void:
	if stages.is_empty() or is_selected:
		return
	stage_index = (stage_index + 1) % stages.size()
	_play_sfx_feedback(false)
	_update_stage_display(true)

func prev_stage() -> void:
	if stages.is_empty() or is_selected:
		return
	stage_index = (stage_index - 1 + stages.size()) % stages.size()
	_play_sfx_feedback(false)
	_update_stage_display(true)

func set_stage_index(index: int) -> void:
	if is_selected or index == stage_index or index < 0 or index >= stages.size():
		return
	stage_index = index
	_play_sfx_feedback(false)
	_update_stage_display(true)

func select_current_stage() -> void:
	if is_selected or stages.is_empty():
		return
	is_selected = true
	_play_sfx_feedback(true)
	
	# Animación de confirmación
	if card_panel and is_inside_tree():
		var tween: Tween = create_tween()
		if tween:
			tween.tween_property(card_panel, "scale", Vector2(1.04, 1.04), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(card_panel, "scale", Vector2(1.0, 1.0), 0.12)
	
	var chosen_stage_file: String = stage_list[stage_index]
	emit_signal("on_selected_stage", chosen_stage_file)
	emit_signal("stage_selected", chosen_stage_file)

func _on_back_pressed() -> void:
	if is_selected:
		return
	_play_sfx_feedback(false)
	emit_signal("back_requested")

func _unhandled_input(event: InputEvent) -> void:
	if is_selected or not visible:
		return
	
	if event.is_echo():
		return
	
	var is_left: bool = false
	var is_right: bool = false
	var is_confirm: bool = false
	var is_back: bool = false
	
	if event is InputEventKey and event.pressed:
		var code: int = event.keycode if event.keycode != 0 else event.physical_keycode
		if code == KEY_LEFT or code == KEY_A:
			is_left = true
		elif code == KEY_RIGHT or code == KEY_D:
			is_right = true
		elif code == KEY_ENTER or code == KEY_KP_ENTER or code == KEY_SPACE:
			is_confirm = true
		elif code == KEY_ESCAPE:
			is_back = true
	
	if not is_left and (
		event.is_action_pressed("ui_left") or
		event.is_action_pressed("ui_left_1") or
		event.is_action_pressed("ui_left_2") or
		event.is_action_pressed("ui_left_3") or
		event.is_action_pressed("ui_left_4")
	):
		is_left = true
	
	if not is_right and (
		event.is_action_pressed("ui_right") or
		event.is_action_pressed("ui_right_1") or
		event.is_action_pressed("ui_right_2") or
		event.is_action_pressed("ui_right_3") or
		event.is_action_pressed("ui_right_4")
	):
		is_right = true
	
	if not is_confirm and (
		event.is_action_pressed("ui_accept") or
		event.is_action_pressed("ui_kick_1") or
		event.is_action_pressed("ui_kick_2")
	):
		is_confirm = true
	
	if not is_back and event.is_action_pressed("ui_cancel"):
		is_back = true
	
	if is_left:
		if _nav_debounce_timer <= 0.0:
			_nav_debounce_timer = NAV_DEBOUNCE_TIME
			prev_stage()
			if is_inside_tree() and get_viewport():
				get_viewport().set_input_as_handled()
	elif is_right:
		if _nav_debounce_timer <= 0.0:
			_nav_debounce_timer = NAV_DEBOUNCE_TIME
			next_stage()
			if is_inside_tree() and get_viewport():
				get_viewport().set_input_as_handled()
	elif is_confirm:
		select_current_stage()
		if is_inside_tree() and get_viewport():
			get_viewport().set_input_as_handled()
	elif is_back:
		_on_back_pressed()
		if is_inside_tree() and get_viewport():
			get_viewport().set_input_as_handled()

func reset() -> void:
	is_selected = false
	_audio_cooldown = 0.0
	_nav_debounce_timer = 0.0
	if is_inside_tree() and music_player and not music_player.playing:
		music_player.play()
	_update_stage_display(false)
