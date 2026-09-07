class_name CountdownHud extends Control

var panel_container: PanelContainer
var header_label: Label
var timer_label: Label
var progress_bar: ProgressBar

var _panel_style: StyleBoxFlat
var _progress_bg_style: StyleBoxFlat
var _progress_fill_style: StyleBoxFlat

var _current_disease: Disease = null
var _current_afflicted: CharacterBody2D = null
var _total_duration: float = 5.0
var _time_left: float = 0.0
var _is_active: bool = false
var _is_critical: bool = false

var _entry_tween: Tween
var _pulse_tween: Tween
var _fade_tween: Tween

const COLOR_NORMAL_TEXT: Color = Color(1.0, 0.92, 0.35, 1.0)
const COLOR_NORMAL_BORDER: Color = Color(0.95, 0.78, 0.15, 1.0)
const COLOR_NORMAL_FILL: Color = Color(0.95, 0.78, 0.15, 1.0)

const COLOR_WARNING_TEXT: Color = Color(1.0, 0.58, 0.15, 1.0)
const COLOR_WARNING_BORDER: Color = Color(1.0, 0.52, 0.1, 1.0)
const COLOR_WARNING_FILL: Color = Color(1.0, 0.52, 0.1, 1.0)

const COLOR_DANGER_TEXT: Color = Color(1.0, 0.25, 0.28, 1.0)
const COLOR_DANGER_BORDER: Color = Color(1.0, 0.2, 0.25, 1.0)
const COLOR_DANGER_FILL: Color = Color(1.0, 0.18, 0.22, 1.0)

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
	hide_countdown(true)

func _process(_delta: float) -> void:
	if not _is_active:
		return
	
	if _current_disease != null and is_instance_valid(_current_disease) and _current_disease.is_inside_tree():
		if _current_disease.timer and _current_disease.timer.time_left > 0:
			_time_left = _current_disease.timer.get_time_left()
		else:
			_time_left = _current_disease.timeLeft
		_update_display(_time_left)
	else:
		hide_countdown()

func _ensure_ui() -> void:
	if panel_container == null:
		config_ui()

func config_ui() -> void:
	panel_container = PanelContainer.new()
	panel_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = Color(0.06, 0.08, 0.13, 0.92)
	_panel_style.border_color = COLOR_NORMAL_BORDER
	_panel_style.set_border_width_all(2)
	_panel_style.set_corner_radius_all(9)
	_panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.55)
	_panel_style.shadow_size = 6
	_panel_style.shadow_offset = Vector2(0, 2)
	_panel_style.content_margin_left = 16.0
	_panel_style.content_margin_right = 16.0
	_panel_style.content_margin_top = 5.0
	_panel_style.content_margin_bottom = 6.0
	panel_container.add_theme_stylebox_override("panel", _panel_style)
	
	panel_container.layout_mode = 1
	panel_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel_container.grow_vertical = Control.GROW_DIRECTION_END
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel_container.offset_top = 12.0
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 1)
	
	header_label = Label.new()
	header_label.text = "☣ INFECCIÓN ACTIVA"
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_label.add_theme_font_size_override("font_size", 10)
	header_label.add_theme_color_override("font_color", Color(0.85, 0.92, 1.0, 0.95))
	header_label.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08, 1.0))
	header_label.add_theme_constant_override("outline_size", 2)
	header_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	header_label.add_theme_constant_override("shadow_offset_x", 1)
	header_label.add_theme_constant_override("shadow_offset_y", 1)
	
	timer_label = Label.new()
	timer_label.text = "0.00"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.add_theme_color_override("font_color", COLOR_NORMAL_TEXT)
	timer_label.add_theme_color_override("font_outline_color", Color(0.04, 0.04, 0.06, 1.0))
	timer_label.add_theme_constant_override("outline_size", 4)
	timer_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	timer_label.add_theme_constant_override("shadow_offset_x", 1)
	timer_label.add_theme_constant_override("shadow_offset_y", 1)
	
	progress_bar = ProgressBar.new()
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size = Vector2(110, 3)
	progress_bar.min_value = 0.0
	progress_bar.max_value = 1.0
	progress_bar.value = 1.0
	
	_progress_bg_style = StyleBoxFlat.new()
	_progress_bg_style.bg_color = Color(0.12, 0.14, 0.18, 0.8)
	_progress_bg_style.set_corner_radius_all(3)
	
	_progress_fill_style = StyleBoxFlat.new()
	_progress_fill_style.bg_color = COLOR_NORMAL_FILL
	_progress_fill_style.set_corner_radius_all(3)
	
	progress_bar.add_theme_stylebox_override("background", _progress_bg_style)
	progress_bar.add_theme_stylebox_override("fill", _progress_fill_style)
	
	vbox.add_child(header_label)
	vbox.add_child(timer_label)
	vbox.add_child(progress_bar)
	
	panel_container.add_child(vbox)
	panel_container.visible = false
	add_child(panel_container)

func start_countdown(disease: Disease, afflicted_player: CharacterBody2D = null) -> void:
	_ensure_ui()
	_kill_tweens()
	
	_current_disease = disease
	_current_afflicted = afflicted_player
	_is_active = true
	_is_critical = false
	
	if disease != null:
		if "LIFE_EXPECTANCY" in disease:
			_total_duration = float(disease.LIFE_EXPECTANCY)
		elif "total_duration" in disease and disease.total_duration > 0:
			_total_duration = disease.total_duration
		elif disease.timer and disease.timer.wait_time > 0:
			_total_duration = disease.timer.wait_time
		else:
			_total_duration = 5.0
		
		if disease.timer and disease.timer.time_left > 0:
			_time_left = disease.timer.get_time_left()
		else:
			_time_left = _total_duration
	else:
		_total_duration = 5.0
		_time_left = 5.0
	
	_update_header_text()
	_update_display(_time_left)
	
	panel_container.visible = true
	panel_container.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	# Asegurar pivote centrado
	panel_container.scale = Vector2.ONE
	panel_container.rotation = 0.0
	panel_container.reset_size()
	var container_size: Vector2 = panel_container.get_combined_minimum_size()
	panel_container.size = container_size
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel_container.offset_top = 12.0
	panel_container.pivot_offset = Vector2(container_size.x / 2.0, container_size.y / 2.0)
	
	if is_inside_tree():
		panel_container.scale = Vector2(0.5, 0.5)
		panel_container.modulate.a = 0.0
		
		_entry_tween = create_tween()
		_entry_tween.set_trans(Tween.TRANS_BACK)
		_entry_tween.set_ease(Tween.EASE_OUT)
		_entry_tween.parallel().tween_property(panel_container, "scale", Vector2(1.0, 1.0), 0.35)
		_entry_tween.parallel().tween_property(panel_container, "modulate:a", 1.0, 0.25)

func _update_header_text() -> void:
	var disease_title: String = "INFECCIÓN"
	if _current_disease != null:
		var raw_name: String = ""
		if "_name" in _current_disease:
			raw_name = str(_current_disease._name)
		elif "name" in _current_disease:
			raw_name = str(_current_disease.name)
		
		if raw_name == "SpontaneousCombustion":
			disease_title = "🔥 COMBUSTIÓN ESPONTÁNEA"
		elif raw_name == "FulminatingDiarrhea":
			disease_title = "☣ DIARREA FULMINANTE"
		elif raw_name != "":
			disease_title = "☣ " + raw_name.to_upper()
	
	var player_name: String = ""
	if _current_afflicted != null and "nickname" in _current_afflicted:
		player_name = str(_current_afflicted.nickname).to_upper()
	
	if player_name != "":
		header_label.text = disease_title + " • " + player_name
	else:
		header_label.text = disease_title

func _update_display(time_remaining: float) -> void:
	var clamped_time: float = max(0.0, time_remaining)
	
	# Formato digital nítido con segundos y centésimas (ej: 04.85)
	var seconds_int: int = int(clamped_time)
	var fractions: int = int((clamped_time - seconds_int) * 100.0)
	timer_label.text = "%02d.%02d" % [seconds_int, fractions]
	
	# Actualizar barra de progreso
	if _total_duration > 0.0:
		progress_bar.value = clamp(clamped_time / _total_duration, 0.0, 1.0)
	
	# Transición de estilos según la urgencia
	if clamped_time > 3.0:
		_set_theme_colors(COLOR_NORMAL_TEXT, COLOR_NORMAL_BORDER, COLOR_NORMAL_FILL)
		_stop_critical_pulse()
	elif clamped_time > 1.5:
		_set_theme_colors(COLOR_WARNING_TEXT, COLOR_WARNING_BORDER, COLOR_WARNING_FILL)
		_stop_critical_pulse()
	else:
		_set_theme_colors(COLOR_DANGER_TEXT, COLOR_DANGER_BORDER, COLOR_DANGER_FILL)
		_start_critical_pulse()

func _set_theme_colors(text_color: Color, border_color: Color, fill_color: Color) -> void:
	if timer_label:
		timer_label.add_theme_color_override("font_color", text_color)
	if _panel_style:
		_panel_style.border_color = border_color
	if _progress_fill_style:
		_progress_fill_style.bg_color = fill_color

func _start_critical_pulse() -> void:
	if _is_critical:
		return
	_is_critical = true
	
	if not is_inside_tree():
		return
	
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	
	panel_container.scale = Vector2.ONE
	panel_container.rotation = 0.0
	panel_container.reset_size()
	var container_size: Vector2 = panel_container.get_combined_minimum_size()
	panel_container.size = container_size
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel_container.offset_top = 12.0
	panel_container.pivot_offset = Vector2(container_size.x / 2.0, container_size.y / 2.0)
	
	_pulse_tween = create_tween().set_loops()
	_pulse_tween.set_trans(Tween.TRANS_SINE)
	_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	_pulse_tween.tween_property(panel_container, "scale", Vector2(1.08, 1.08), 0.22)
	_pulse_tween.tween_property(panel_container, "scale", Vector2(1.0, 1.0), 0.22)

func _stop_critical_pulse() -> void:
	if not _is_critical:
		return
	_is_critical = false
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	if panel_container:
		panel_container.scale = Vector2(1.0, 1.0)

func stop_countdown(player: CharacterBody2D = null) -> void:
	if player != null and _current_afflicted != null and player != _current_afflicted:
		return
	hide_countdown()

func hide_countdown(immediate: bool = false) -> void:
	_is_active = false
	_current_disease = null
	_current_afflicted = null
	_kill_tweens()
	
	if panel_container == null:
		return
	
	if immediate or not is_inside_tree():
		panel_container.visible = false
		panel_container.modulate.a = 0.0
		panel_container.scale = Vector2(1.0, 1.0)
	else:
		_fade_tween = create_tween()
		_fade_tween.set_trans(Tween.TRANS_QUAD)
		_fade_tween.set_ease(Tween.EASE_IN_OUT)
		_fade_tween.parallel().tween_property(panel_container, "modulate:a", 0.0, 0.25)
		_fade_tween.parallel().tween_property(panel_container, "scale", Vector2(0.8, 0.8), 0.25)
		_fade_tween.chain().tween_callback(Callable(self, "_on_fade_out_finished"))

func _on_fade_out_finished() -> void:
	if not _is_active and panel_container:
		panel_container.visible = false
		panel_container.scale = Vector2(1.0, 1.0)

func _kill_tweens() -> void:
	if _entry_tween and _entry_tween.is_valid():
		_entry_tween.kill()
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	_is_critical = false
