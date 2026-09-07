class_name DiseaseAnnouncement extends Control

signal announcement_finished

var panel_container: PanelContainer
var vbox: VBoxContainer
var subtitle_label: Label
var title_label: Label
var shadow_decor_top: Label
var shadow_decor_bottom: Label

var _panel_style: StyleBoxFlat
var _anim_tween: Tween
var _is_displaying: bool = false

# Paletas de color retro años 90 (estilo arcade / beat 'em up / fighting games)
const COLOR_FIRE_PRIMARY: Color = Color(1.0, 0.35, 0.05, 1.0)
const COLOR_FIRE_ACCENT: Color = Color(1.0, 0.88, 0.2, 1.0)
const COLOR_FIRE_BORDER: Color = Color(1.0, 0.2, 0.0, 1.0)

const COLOR_TOXIC_PRIMARY: Color = Color(0.4, 0.95, 0.1, 1.0)
const COLOR_TOXIC_ACCENT: Color = Color(0.85, 1.0, 0.3, 1.0)
const COLOR_TOXIC_BORDER: Color = Color(0.25, 0.8, 0.1, 1.0)

const COLOR_GENERIC_PRIMARY: Color = Color(1.0, 0.2, 0.5, 1.0)
const COLOR_GENERIC_ACCENT: Color = Color(1.0, 0.9, 0.3, 1.0)
const COLOR_GENERIC_BORDER: Color = Color(0.9, 0.1, 0.4, 1.0)

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
	hide_announcement(true)

func _ensure_ui() -> void:
	if panel_container == null:
		config_ui()

func config_ui() -> void:
	panel_container = PanelContainer.new()
	panel_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = Color(0.04, 0.05, 0.09, 0.92)
	_panel_style.border_color = COLOR_FIRE_BORDER
	_panel_style.set_border_width_all(4)
	_panel_style.set_corner_radius_all(12)
	_panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.85)
	_panel_style.shadow_size = 14
	_panel_style.shadow_offset = Vector2(0, 5)
	_panel_style.content_margin_left = 32.0
	_panel_style.content_margin_right = 32.0
	_panel_style.content_margin_top = 10.0
	_panel_style.content_margin_bottom = 12.0
	panel_container.add_theme_stylebox_override("panel", _panel_style)
	
	panel_container.layout_mode = 1
	panel_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel_container.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 2)
	
	# Subtítulo estilo retro: "¡NUEVA ENFERMEDAD!" / "DISEASE ALERT"
	subtitle_label = Label.new()
	subtitle_label.text = "⚡ ¡¡ ALERTA BIOLÓGICA !! ⚡"
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 13)
	subtitle_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.5, 1.0))
	subtitle_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	subtitle_label.add_theme_constant_override("outline_size", 3)
	subtitle_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	subtitle_label.add_theme_constant_override("shadow_offset_x", 1)
	subtitle_label.add_theme_constant_override("shadow_offset_y", 1)
	
	# Título principal en grande con estética arcade 90s (letras pesadas, contorno grueso y sombra profunda)
	title_label = Label.new()
	title_label.text = "COMBUSTIÓN ESPONTÁNEA"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 44)
	title_label.add_theme_color_override("font_color", COLOR_FIRE_ACCENT)
	title_label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.03, 1.0))
	title_label.add_theme_constant_override("outline_size", 10)
	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	title_label.add_theme_constant_override("shadow_offset_x", 4)
	title_label.add_theme_constant_override("shadow_offset_y", 4)
	
	vbox.add_child(subtitle_label)
	vbox.add_child(title_label)
	
	panel_container.add_child(vbox)
	add_child(panel_container)

func announce_disease(disease: Variant) -> void:
	var raw_name: String = ""
	if disease == null:
		return
	
	if disease is String:
		raw_name = disease
	elif disease is Object:
		if "_name" in disease:
			raw_name = str(disease._name)
		elif "name" in disease:
			raw_name = str(disease.name)
	
	var display_title: String = "ENFERMEDAD"
	var primary_color: Color = COLOR_GENERIC_PRIMARY
	var accent_color: Color = COLOR_GENERIC_ACCENT
	var border_color: Color = COLOR_GENERIC_BORDER
	
	if raw_name == "SpontaneousCombustion":
		display_title = "🔥 COMBUSTIÓN ESPONTÁNEA 🔥"
		primary_color = COLOR_FIRE_PRIMARY
		accent_color = COLOR_FIRE_ACCENT
		border_color = COLOR_FIRE_BORDER
	elif raw_name == "FulminatingDiarrhea":
		display_title = "☣ DIARREA FULMINANTE ☣"
		primary_color = COLOR_TOXIC_PRIMARY
		accent_color = COLOR_TOXIC_ACCENT
		border_color = COLOR_TOXIC_BORDER
	elif raw_name != "":
		display_title = "☣ " + raw_name.to_upper() + " ☣"
	
	show_announcement(display_title, primary_color, accent_color, border_color)

func show_announcement(text: String, primary_color: Color, accent_color: Color, border_color: Color) -> void:
	_ensure_ui()
	_kill_tween()
	
	title_label.text = text
	title_label.add_theme_color_override("font_color", accent_color)
	_panel_style.border_color = border_color
	subtitle_label.add_theme_color_override("font_color", primary_color)
	
	panel_container.visible = true
	panel_container.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# Centrar pivote para animación de zoom/escala estilo 90s arcade
	panel_container.scale = Vector2.ONE
	panel_container.rotation = 0.0
	panel_container.reset_size()
	var container_size: Vector2 = panel_container.get_combined_minimum_size()
	panel_container.size = container_size
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_container.pivot_offset = Vector2(container_size.x / 2.0, container_size.y / 2.0)
	
	_is_displaying = true
	
	if not is_inside_tree():
		return
	
	# Animación estilo Arcade 90s:
	# 1. Aparece con un golpe de escala rápida gigante -> tamaño normal (slam punch)
	# 2. Pequeño rebote/vibración de impacto
	# 3. Permanece visible por un instante
	# 4. Desaparece suavemente desvaneciéndose y expandiéndose
	panel_container.scale = Vector2(2.5, 2.5)
	panel_container.modulate.a = 0.0
	
	_anim_tween = create_tween()
	
	# Entrada rápida e impactante
	_anim_tween.set_trans(Tween.TRANS_BACK)
	_anim_tween.set_ease(Tween.EASE_OUT)
	_anim_tween.parallel().tween_property(panel_container, "scale", Vector2(1.0, 1.0), 0.28)
	_anim_tween.parallel().tween_property(panel_container, "modulate:a", 1.0, 0.15)
	
	# Pequeño pulso sostenido durante la exhibición
	_anim_tween.chain().tween_property(panel_container, "scale", Vector2(1.06, 1.06), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_anim_tween.tween_property(panel_container, "scale", Vector2(1.0, 1.0), 0.45).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Desvanecimiento y salida
	_anim_tween.chain().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_anim_tween.parallel().tween_property(panel_container, "modulate:a", 0.0, 0.35)
	_anim_tween.parallel().tween_property(panel_container, "scale", Vector2(1.3, 1.3), 0.35)
	
	_anim_tween.chain().tween_callback(Callable(self, "_on_announcement_finished"))

func _on_announcement_finished() -> void:
	_is_displaying = false
	if panel_container:
		panel_container.visible = false
		panel_container.scale = Vector2.ONE
	announcement_finished.emit()

func hide_announcement(immediate: bool = false) -> void:
	_is_displaying = false
	_kill_tween()
	if panel_container == null:
		return
	
	if immediate or not is_inside_tree():
		panel_container.visible = false
		panel_container.modulate.a = 0.0
		panel_container.scale = Vector2.ONE
	else:
		_anim_tween = create_tween()
		_anim_tween.tween_property(panel_container, "modulate:a", 0.0, 0.2)
		_anim_tween.tween_callback(Callable(self, "_on_announcement_finished"))

func _kill_tween() -> void:
	if _anim_tween and _anim_tween.is_valid():
		_anim_tween.kill()
