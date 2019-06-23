class_name Movement extends GDScript

const UP = Vector2(0, -1)
const GRAVITY = 0
const ACCELERARION = 50
const MAX_SPEED = 200
const JUMP_WEIGHT = -550

var motion = Vector2()
var currentCollider = ""

func _ready():
	pass
	
func wasd_controller(delta):
	var friction = false
	motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right"):
		motion.x = min(motion.x + ACCELERARION, MAX_SPEED)
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERARION, -MAX_SPEED)
	elif Input.is_action_pressed("ui_down"):
		motion.y = min(motion.y + ACCELERARION, MAX_SPEED)
	elif Input.is_action_pressed("ui_up"):
		motion.y = max(motion.y - ACCELERARION, -MAX_SPEED)
	else:
		friction = true
		
