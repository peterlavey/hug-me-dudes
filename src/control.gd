class_name Movement extends GDScript

export var this = ''
export var up = Vector2(0, -1)
export var gravity = 20
export var acceleration = 50
export var maxSpeed = 200
export var jumpWeight = -550
export var motion = Vector2()
export var currentCollider = ""

func _ready():
	pass
	
