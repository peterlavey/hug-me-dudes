class_name Body extends KinematicBody2D

export var Movement = preload("res://src/control.gd")
export var controll:GDScript = Movement.new()
var sprite:Sprite = Sprite.new()
var texture:Texture = Texture.new()

func _ready():

	pass
	
func _init():
	sprite.texture = texture.set
	
func _physics_process(delta):
	controll.start()
	controll.motion = move_and_slide(controll.motion, controll.up)
