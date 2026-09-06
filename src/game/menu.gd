class_name Menu extends Node2D

var background:Sprite2D = Sprite2D.new()
var startButton:LinkButton = LinkButton.new()
var buttonTimer:Timer = Timer.new()
var isInitiated:bool = false
var musicPlayer = AudioStreamPlayer2D.new()
signal on_menu_start

func _ready():
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
	
	var view_size: Vector2 = get_viewport_rect().size
	startButton.position.x = (view_size.x / 2.0) - 60.0
	startButton.position.y = view_size.y / 2.0
	
	startButton.scale = Vector2(2, 2)
	
	add_child(startButton)

func config_animation()-> void:
	buttonTimer.connect("timeout", Callable(self, "animate_button"))
	buttonTimer.set_wait_time(0.5)
	add_child(buttonTimer)
	buttonTimer.start()

func reset() -> void:
	isInitiated = false
	if musicPlayer and not musicPlayer.playing:
		musicPlayer.play()

func animate_button()-> void:
	if startButton.is_visible_in_tree():
		startButton.hide()
	else:
		startButton.show()