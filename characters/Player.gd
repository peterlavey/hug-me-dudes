extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELERARION = 50
const MAX_SPEED = 200
const JUMP_WEIGHT = -550

var motion = Vector2()
var currentCollider = ""

func _ready():
	pass
	
func _physics_process(delta):
	var friction = false
	motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right"):
		motion.x = min(motion.x + ACCELERARION, MAX_SPEED)
	elif Input.is_action_pressed("ui_left"):
		motion.x = max(motion.x - ACCELERARION, -MAX_SPEED)
	else:
		friction = true
	
	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			motion.y = JUMP_WEIGHT
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.2)
	else:
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)
	
	
	motion = move_and_slide(motion, UP)
	
	_onPlayerCollides()
	_deathWith("Spike")
	
	pass

func _onPlayerCollides():
	for i in get_slide_count():
    	currentCollider = get_slide_collision(i).collider.name	

func _deathWith(killer):
	if currentCollider == killer:
		queue_free()	