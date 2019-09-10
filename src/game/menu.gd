class_name Menu extends Node2D

var background:Sprite = Sprite.new()
var startButton:LinkButton = LinkButton.new()
var buttonTimer:Timer = Timer.new()
var isInitiated:bool = false
var musicPlayer = AudioStreamPlayer2D.new()
signal on_menu_start

func _init():
	config_background()
	config_button()
	config_animation()
	config_music()
	pass

func config_music()-> void:
	var song = load("res://sounds/menu/sea.ogg")
	musicPlayer.stream = song
	add_child(musicPlayer)
	musicPlayer.play()

func menu_start()-> void:
	isInitiated = true
	emit_signal("on_menu_start")

func _process(delta):
	if !isInitiated:
		listen_start_button()

func listen_start_button()-> void:
	if Input.is_action_pressed("ui_accept"):
		menu_start()

func config_background()-> void:
	background.texture = load("res://sprites/menu/start.jpg")
	background.centered = false
	
	add_child(background)

func config_button()-> void:
	startButton.text = "Press Start!"
	
	startButton.underline = LinkButton.UNDERLINE_MODE_NEVER
	
	startButton.rect_position.x = (OS.get_window_size().x / 2) - 60
	startButton.rect_position.y = OS.get_window_size().y / 2
	
	startButton.rect_scale = Vector2(2, 2)
	
	add_child(startButton)

func config_animation()-> void:
	buttonTimer.connect("timeout", self, "animate_button")
	buttonTimer.set_wait_time(0.5)
	buttonTimer.start()
	
	add_child(buttonTimer)

func animate_button()-> void:
	if startButton.is_visible_in_tree():
		startButton.hide()
	else:
		startButton.show()