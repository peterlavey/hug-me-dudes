class_name Body extends KinematicBody2D

var Movement = preload("res://src/movement.gd")

export var control:GDScript = Movement.new()
var texture:Texture = Texture.new()
var playerSprite = Sprite.new()
var spriteImage = load("res://sprites/icon.png")	
export var edad = 123

func _ready():
	pass
	
func _init():
	print("Body instanciado")
	load_texture()
	
func _physics_process(delta):
	control.wasd_controller(delta)
	control.motion = move_and_slide(control.motion, control.UP)
	
	
func load_texture():
	playerSprite.set_texture(spriteImage)	
	add_child(playerSprite)