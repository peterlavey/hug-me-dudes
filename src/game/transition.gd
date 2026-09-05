class_name Transition extends Node

var screen = Sprite2D.new()
var alpha = 0
var isComplete = true
var processSelected = 0
var callback = 0
@export var speed = 1
signal on_blackout

const PROCESS = {
	"LIGHT_TO_DARK_TO_LIGHT": 0,
	"DARK_TO_LIGHT": 1
}

func _ready():
	config_screen()

func config_screen()-> void:
	screen.texture = load("res://sprites/black.png")
	screen.centered = false
	screen.scale.x = get_window().get_size().x * 0.01
	screen.scale.y = get_window().get_size().y * 0.01
	screen.modulate = Color8(0, 0, 0, 0)
	if screen.get_parent() == null:
		add_child(screen)

func dark_to_light()-> void:
	alpha = 255
	if screen.get_parent() == null:
		add_child(screen)
	processSelected = PROCESS.DARK_TO_LIGHT
	isComplete = false

func light_to_dark_to_light()-> void:
	alpha = 0
	callback = 0
	if screen.get_parent() == null:
		add_child(screen)
	processSelected = PROCESS.LIGHT_TO_DARK_TO_LIGHT
	isComplete = false

func _process(delta):
	if !isComplete:
		if processSelected == PROCESS.LIGHT_TO_DARK_TO_LIGHT:
			light_to_dark_to_light_process()
		elif processSelected == PROCESS.DARK_TO_LIGHT:
			dark_to_light_process()

func dark_to_light_process():
	if alpha > 0:
		screen.modulate = Color8(0, 0, 0, alpha)
		alpha -= speed
	else:
		screen.modulate = Color8(0, 0, 0, 0)
		isComplete = true

func light_to_dark_to_light_process():
	if callback == 0 && alpha < 255:
		screen.modulate = Color8(0, 0, 0, alpha)
		alpha += speed
	elif alpha > 253 && callback == 0:
		emit_signal("on_blackout")
		callback += 1
	elif callback == 1:
		dark_to_light_process()