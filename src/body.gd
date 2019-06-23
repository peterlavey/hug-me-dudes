class_name Body extends KinematicBody2D

#export var Movement = preload("res://src/movement.gd")
#export var control:GDScript = Movement.new()
var sprite:Sprite = Sprite.new()
var texture:Texture = Texture.new()
export var edad = 123

func _ready():

	pass
	
func _init():
	print("Body instanciado")
	#sprite.texture = texture.set
	
func _physics_process(delta):
	#control.start()
	#control.motion = move_and_slide(control.motion, control.up)
	pass