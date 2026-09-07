class_name MusicPlayer extends AudioStreamPlayer2D

@export var songs: Array = []
@export var shuffle: bool = true
@export var currentSong: String = ""
var currentIndex: int = 0

var input: Control
var hud_layer: CanvasLayer
var hud_root: MarginContainer
var hud_panel: PanelContainer
var song_label: Label
var header_label: Label
var icon_label: Label
var _hud_tween: Tween
var _pending_play: bool = false

func _init() -> void:
	config_hud()
	finished.connect(next_song)

func _ready() -> void:
	if hud_layer and hud_layer.get_parent() == null:
		add_child(hud_layer)
	
	if _pending_play:
		_pending_play = false
		start()
	elif not currentSong.is_empty():
		show_hud()

func set_songs(_songs: Array) -> void:
	songs = _songs.duplicate()
	if shuffle:
		songs.shuffle()

func next_song() -> void:
	stop()
	set_next_song()
	start()

func start() -> void:
	if songs.is_empty():
		return
	
	set_current_song()
	load_song()
	
	if not is_inside_tree():
		_pending_play = true
		return
	
	play()
	show_hud()

func set_current_song() -> void:
	if songs.is_empty():
		return
	currentSong = songs[currentIndex]
	var song_title: String = currentSong.get_basename()
	if song_label:
		song_label.text = song_title
	if input and input != song_label and input.has_method("set_text"):
		input.set_text(song_title)

func load_song() -> void:
	if currentSong.is_empty():
		return
	var song_path: String = "res://sounds/ost/" + currentSong
	if ResourceLoader.exists(song_path):
		var song: AudioStream = load(song_path)
		stream = song

func set_next_song() -> void:
	if songs.is_empty():
		return
	if currentIndex < songs.size() - 1:
		currentIndex += 1
	else:
		currentIndex = 0

func config_hud() -> void:
	if hud_layer != null:
		return
	
	hud_layer = CanvasLayer.new()
	hud_layer.layer = 12
	
	hud_root = MarginContainer.new()
	hud_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	hud_root.anchor_right = 1.0
	hud_root.anchor_bottom = 1.0
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_theme_constant_override("margin_right", 24)
	hud_root.add_theme_constant_override("margin_bottom", 24)
	
	hud_panel = PanelContainer.new()
	hud_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	hud_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	hud_panel.modulate.a = 0.0
	hud_panel.visible = false
	
	var panel_style: StyleBoxFlat = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.07, 0.12, 0.90)
	panel_style.border_color = Color(0.25, 0.70, 1.0, 0.85)
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(10)
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.75)
	panel_style.shadow_size = 10
	panel_style.shadow_offset = Vector2(0, 4)
	panel_style.content_margin_left = 16.0
	panel_style.content_margin_right = 20.0
	panel_style.content_margin_top = 8.0
	panel_style.content_margin_bottom = 10.0
	hud_panel.add_theme_stylebox_override("panel", panel_style)
	
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_theme_constant_override("separation", 12)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	icon_label = Label.new()
	icon_label.text = "🎵"
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 22)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_theme_constant_override("separation", 2)
	
	header_label = Label.new()
	header_label.text = "♪ REPRODUCIENDO"
	header_label.add_theme_font_size_override("font_size", 10)
	header_label.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1.0))
	header_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	header_label.add_theme_constant_override("outline_size", 2)
	
	song_label = Label.new()
	song_label.text = ""
	song_label.add_theme_font_size_override("font_size", 14)
	song_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	song_label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.04, 1.0))
	song_label.add_theme_constant_override("outline_size", 3)
	song_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	song_label.add_theme_constant_override("shadow_offset_x", 1)
	song_label.add_theme_constant_override("shadow_offset_y", 1)
	
	vbox.add_child(header_label)
	vbox.add_child(song_label)
	
	hbox.add_child(icon_label)
	hbox.add_child(vbox)
	
	hud_panel.add_child(hbox)
	hud_root.add_child(hud_panel)
	hud_layer.add_child(hud_root)
	add_child(hud_layer)
	
	input = song_label

func show_hud() -> void:
	if hud_panel == null:
		return
	
	if not is_inside_tree():
		return
	
	if _hud_tween and _hud_tween.is_valid():
		_hud_tween.kill()
	
	hud_panel.visible = true
	_hud_tween = create_tween()
	
	# Efecto suave de aparición (Fade In de 0.4s)
	_hud_tween.tween_property(hud_panel, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	# Se muestra durante 3 segundos para alcanzar a leer el título
	_hud_tween.tween_interval(3.0)
	# Efecto suave de desaparición (Fade Out de 0.6s)
	_hud_tween.tween_property(hud_panel, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	# Ocultar panel al finalizar la transición
	_hud_tween.tween_callback(func() -> void:
		if is_instance_valid(hud_panel) and hud_panel.modulate.a <= 0.01:
			hud_panel.visible = false
	)

func _process(_delta: float) -> void:
	if stream != null and song_is_finished():
		next_song()

func song_is_finished() -> bool:
	if stream == null or not playing:
		return false
	return get_playback_position() > stream.get_length() - 0.05