class_name StageSelect extends Node2D

var menu = Node2D.new()
var isInitiated:bool = false
var background:Sprite = Sprite.new()
var musicPlayer = AudioStreamPlayer2D.new()
var stages:Array
var stageIndex = 0
var folderManager = load("res://src/utils/folderManager.gd").new()
signal on_selected_stage

func _init():
	config_background()
	config_music()
	config_menu()
	config_stages()
	pass

func config_menu()-> void:
	var width = OS.get_window_size().x
	var height = OS.get_window_size().y
	
	menu.scale.x = 0.4
	menu.scale.y = 0.4
	
	menu.position.x = (width / 2) - (width * 0.2)
	menu.position.y = (height / 2) - (height * 0.2)
	
	add_child(menu)

func config_stages()-> void:
	var stageList = folderManager.get_directory_list("res://stages", "tscn")
	
	for stage in stageList:
		stages.append(load("res://stages/" + stage))
	
	menu.add_child(stages[stageIndex].instance())

func config_music()-> void:
	var song = load("res://sounds/menu/sea.ogg")
	musicPlayer.stream = song
	add_child(musicPlayer)
	#musicPlayer.play()

func listen_start_button()-> void:
	if Input.is_action_just_released("ui_left_1") && stageIndex > 0:
		left()
	if Input.is_action_just_released("ui_right_1") && stageIndex < stages.size() - 1:
		right()
	if Input.is_action_pressed("ui_accept"):
		select()

func left()-> void:
	menu.remove_child(stages[stageIndex].instance())
	stageIndex -= 1
	menu.add_child(stages[stageIndex].instance())
	pass

func right()-> void:
	menu.remove_child(stages[stageIndex].instance())
	stageIndex += 1
	menu.add_child(stages[stageIndex].instance())
	pass

func select()-> void:
	isInitiated = true
	emit_signal("on_selected_stage")

func config_background()-> void:
	background.texture = load("res://sprites/menu/start.jpg")
	background.centered = false
	
	add_child(background)

func _process(delta):
	if !isInitiated:
		listen_start_button()