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

func start():
	var friction = false
	motion.y += gravity
	
	if Input.is_action_pressed("ui_right"):
		print(motion.x)
		motion.x = min(motion.x + acceleration, maxSpeed)
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - acceleration, -maxSpeed)
	else:
		friction = true
	
