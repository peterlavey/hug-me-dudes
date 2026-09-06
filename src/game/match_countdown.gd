class_name MatchCountdown extends Control

signal step_changed(step_number: int, step_text: String)
signal countdown_finished

var panel_container: PanelContainer
var count_label: Label
var subtitle_label: Label
var particles_left: CPUParticles2D
var particles_right: CPUParticles2D
var audio_player: AudioStreamPlayer

var _panel_style: StyleBoxFlat
var _step_tween: Tween
var _fade_tween: Tween
var _current_step: int = 3
var _is_counting: bool = false
var _step_duration: float = 0.85

var _beep_sounds: Dictionary = {}

const COLOR_STEP_3: Color = Color(0.2, 0.85, 1.0, 1.0)
const COLOR_STEP_2: Color = Color(1.0, 0.85, 0.15, 1.0)
const COLOR_STEP_1: Color = Color(1.0, 0.35, 0.2, 1.0)
const COLOR_STEP_GO: Color = Color(0.3, 1.0, 0.4, 1.0)

const SUBTITLE_STEP_3: String = "¡PREPARADOS!"
const SUBTITLE_STEP_2: String = "¡BUSCAD VÍCTIMA!"
const SUBTITLE_STEP_1: String = "¡VIRUS LIBERADO!"
const SUBTITLE_STEP_GO: String = "☣ ¡¡CONTAGIAD O MORID!! ☣"

func _init() -> void:
	_ensure_ui()
	_init_audio()

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
	_init_audio()
	hide_display()

func _ensure_ui() -> void:
	if panel_container == null:
		config_ui()
		config_particles()

func config_ui() -> void:
	panel_container = PanelContainer.new()
	panel_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_panel_style = StyleBoxFlat.new()
	_panel_style.bg_color = Color(0.06, 0.08, 0.14, 0.94)
	_panel_style.border_color = COLOR_STEP_3
	_panel_style.set_border_width_all(3)
	_panel_style.set_corner_radius_all(16)
	_panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.7)
	_panel_style.shadow_size = 12
	_panel_style.shadow_offset = Vector2(0, 4)
	_panel_style.content_margin_left = 40.0
	_panel_style.content_margin_right = 40.0
	_panel_style.content_margin_top = 16.0
	_panel_style.content_margin_bottom = 16.0
	panel_container.add_theme_stylebox_override("panel", _panel_style)
	
	panel_container.layout_mode = 1
	panel_container.anchors_preset = Control.PRESET_CENTER
	panel_container.anchor_left = 0.5
	panel_container.anchor_right = 0.5
	panel_container.anchor_top = 0.5
	panel_container.anchor_bottom = 0.5
	panel_container.offset_left = 0.0
	panel_container.offset_right = 0.0
	panel_container.offset_top = 0.0
	panel_container.offset_bottom = 0.0
	panel_container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel_container.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 6)
	
	count_label = Label.new()
	count_label.text = "3"
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	count_label.add_theme_font_size_override("font_size", 72)
	count_label.add_theme_color_override("font_color", COLOR_STEP_3)
	count_label.add_theme_color_override("font_outline_color", Color(0.02, 0.03, 0.06, 1.0))
	count_label.add_theme_constant_override("outline_size", 10)
	count_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	count_label.add_theme_constant_override("shadow_offset_x", 4)
	count_label.add_theme_constant_override("shadow_offset_y", 4)
	
	subtitle_label = Label.new()
	subtitle_label.text = SUBTITLE_STEP_3
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 16)
	subtitle_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 0.95))
	subtitle_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.9))
	subtitle_label.add_theme_constant_override("outline_size", 4)
	subtitle_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.85))
	subtitle_label.add_theme_constant_override("shadow_offset_x", 2)
	subtitle_label.add_theme_constant_override("shadow_offset_y", 2)
	
	vbox.add_child(count_label)
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
	emitter.amount = 35
	emitter.lifetime = 1.4
	emitter.explosiveness = 0.9
	emitter.direction = direction
	emitter.spread = 45.0
	emitter.initial_velocity_min = 160.0
	emitter.initial_velocity_max = 300.0
	emitter.scale_amount_min = 3.0
	emitter.scale_amount_max = 6.0
	emitter.gravity = Vector2(0.0, 260.0)
	emitter.color = Color(1.0, 0.9, 0.3, 1.0)
	return emitter

func _init_audio() -> void:
	if audio_player == null:
		audio_player = AudioStreamPlayer.new()
		audio_player.volume_db = -18.0
		add_child(audio_player)
	
	_beep_sounds[3] = _generate_beep(440.0, 0.14, 0.04) # A4
	_beep_sounds[2] = _generate_beep(554.37, 0.14, 0.04) # C#5
	_beep_sounds[1] = _generate_beep(659.25, 0.16, 0.05) # E5
	_beep_sounds[0] = _generate_fanfare(0.25, 0.06) # Fanfare

func _generate_beep(frequency: float, duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var sample: float = sin(t * frequency * TAU)
		# Suavizado envolvente
		var env: float = 1.0
		var progress: float = float(i) / float(num_samples)
		if progress < 0.12:
			env = progress / 0.12
		else:
			env = 1.0 - ((progress - 0.12) / 0.88)
		var val: int = int(clamp(sample * env * volume * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)
	
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav

func _generate_fanfare(duration: float, volume: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var num_samples: int = int(sample_rate * duration)
	var data: PackedByteArray = PackedByteArray()
	data.resize(num_samples * 2)
	
	var f1: float = 880.0 # A5
	var f2: float = 1108.73 # C#6
	
	for i in range(num_samples):
		var t: float = float(i) / float(sample_rate)
		var sample: float = (sin(t * f1 * TAU) * 0.6) + (sin(t * f2 * TAU) * 0.4)
		var progress: float = float(i) / float(num_samples)
		var env: float = 1.0
		if progress < 0.1:
			env = progress / 0.1
		else:
			env = (1.0 - progress) * (1.0 - progress)
		var val: int = int(clamp(sample * env * volume * 32767.0, -32768.0, 32767.0))
		data.encode_s16(i * 2, val)
	
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav

func _play_beep(step: int) -> void:
	if audio_player and _beep_sounds.has(step):
		audio_player.stream = _beep_sounds[step]
		audio_player.play()

func is_counting() -> bool:
	return _is_counting

func start_countdown(step_duration: float = 0.85) -> void:
	_ensure_ui()
	_step_duration = step_duration
	_is_counting = true
	_current_step = 3
	
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	if _step_tween and _step_tween.is_valid():
		_step_tween.kill()
	
	panel_container.visible = true
	_animate_step(_current_step)

func _animate_step(step: int) -> void:
	if not is_inside_tree() or not _is_counting:
		return
	
	var step_text: String = ""
	var sub_text: String = ""
	var step_color: Color = COLOR_STEP_3
	var font_size: int = 72
	
	match step:
		3:
			step_text = "3"
			sub_text = SUBTITLE_STEP_3
			step_color = COLOR_STEP_3
			font_size = 76
		2:
			step_text = "2"
			sub_text = SUBTITLE_STEP_2
			step_color = COLOR_STEP_2
			font_size = 76
		1:
			step_text = "1"
			sub_text = SUBTITLE_STEP_1
			step_color = COLOR_STEP_1
			font_size = 76
		0:
			step_text = "¡¡A ABRAZAR!!"
			sub_text = SUBTITLE_STEP_GO
			step_color = COLOR_STEP_GO
			font_size = 46
	
	count_label.text = step_text
	count_label.add_theme_font_size_override("font_size", font_size)
	count_label.add_theme_color_override("font_color", step_color)
	
	subtitle_label.text = sub_text
	_panel_style.border_color = step_color
	
	# Asegurar centrado y pivote
	panel_container.reset_size()
	var container_size: Vector2 = panel_container.get_combined_minimum_size()
	if panel_container.size.x > container_size.x:
		container_size = panel_container.size
	panel_container.pivot_offset = Vector2(container_size.x / 2.0, container_size.y / 2.0)
	
	particles_left.position = Vector2(0.0, container_size.y / 2.0)
	particles_right.position = Vector2(container_size.x, container_size.y / 2.0)
	
	_play_beep(step)
	emit_signal("step_changed", step, step_text)
	
	if _step_tween and _step_tween.is_valid():
		_step_tween.kill()
	
	_step_tween = create_tween()
	
	if step > 0:
		panel_container.modulate = Color(1.0, 1.0, 1.0, 0.0)
		panel_container.scale = Vector2(1.7, 1.7)
		panel_container.rotation = randf_range(-0.06, 0.06)
		
		_step_tween.set_parallel(true)
		_step_tween.set_trans(Tween.TRANS_BACK)
		_step_tween.set_ease(Tween.EASE_OUT)
		_step_tween.tween_property(panel_container, "scale", Vector2(1.0, 1.0), _step_duration * 0.45)
		_step_tween.tween_property(panel_container, "rotation", 0.0, _step_duration * 0.45)
		_step_tween.tween_property(panel_container, "modulate:a", 1.0, _step_duration * 0.25)
		
		# Esperar y pasar al siguiente paso
		_step_tween.set_parallel(false)
		_step_tween.tween_interval(_step_duration * 0.4)
		_step_tween.tween_callback(Callable(self, "_next_step"))
	else:
		# Paso final (GO / ¡A ABRAZAR!)
		panel_container.modulate = Color(1.0, 1.0, 1.0, 0.0)
		panel_container.scale = Vector2(0.3, 0.3)
		panel_container.rotation = 0.0
		
		particles_left.color = COLOR_STEP_GO
		particles_right.color = Color(1.0, 0.85, 0.2, 1.0)
		particles_left.restart()
		particles_right.restart()
		
		_step_tween.set_parallel(true)
		_step_tween.set_trans(Tween.TRANS_ELASTIC)
		_step_tween.set_ease(Tween.EASE_OUT)
		_step_tween.tween_property(panel_container, "scale", Vector2(1.15, 1.15), _step_duration * 0.5)
		_step_tween.tween_property(panel_container, "modulate:a", 1.0, _step_duration * 0.15)
		
		_step_tween.set_parallel(false)
		# Emitir inicio de partida
		_step_tween.tween_callback(Callable(self, "_on_go_reached"))
		_step_tween.tween_interval(_step_duration * 0.75)
		
		# Desvanecer banner
		_step_tween.set_parallel(true)
		_step_tween.set_trans(Tween.TRANS_CUBIC)
		_step_tween.set_ease(Tween.EASE_IN)
		_step_tween.tween_property(panel_container, "scale", Vector2(1.4, 1.4), _step_duration * 0.35)
		_step_tween.tween_property(panel_container, "modulate:a", 0.0, _step_duration * 0.35)
		
		_step_tween.set_parallel(false)
		_step_tween.tween_callback(Callable(self, "hide_display"))

func _next_step() -> void:
	_current_step -= 1
	_animate_step(_current_step)

func _on_go_reached() -> void:
	_is_counting = false
	emit_signal("countdown_finished")

func hide_display() -> void:
	_is_counting = false
	if panel_container:
		panel_container.visible = false
	if particles_left:
		particles_left.emitting = false
	if particles_right:
		particles_right.emitting = false

func stop_countdown() -> void:
	if _step_tween and _step_tween.is_valid():
		_step_tween.kill()
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	hide_display()
