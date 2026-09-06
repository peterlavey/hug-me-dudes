class_name Disease extends Node2D

var label: Label
var timer: Timer
var timeLeft: float
var afflicted: CharacterBody2D

func _init() -> void:
	config_timer()
	config_label()

func _process(delta: float) -> void:
	show_time_left()

func show_time_left() -> void:
	if timer:
		timeLeft = timer.get_time_left()
		if label:
			label.text = str(snapped(timeLeft, 0.01))

func remove_time_left() -> void:
	if label and label.get_parent() == self:
		remove_child(label)
	if timer:
		timer.stop()

func config_label() -> void:
	label = Label.new()
	label.custom_minimum_size = Vector2(80, 30)
	label.size = Vector2(80, 30)
	label.position = Vector2(-40, -80)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 3)
	
	add_child(label)

func config_timer() -> void:
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.connect("timeout", Callable(self, "dead"))
	add_child(timer)

func start(seconds: float) -> void:
	timer.set_wait_time(seconds)
	timer.start()

func dead() -> void:
	pass

func remove_effects() -> void:
	pass

func start_effects() -> void:
	pass
	