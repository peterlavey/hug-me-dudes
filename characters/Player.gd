extends KinematicBody2D

const UP = Vector2(0, -1)
var GRAVITY = 20
var ACCELERARION = 50
var MAX_SPEED = 200
var JUMP_WEIGHT = -550

var motion = Vector2()
var currentCollider = ""

export var id = "1"

func _ready():
	get_parent().connect("test", self, "test2")

	pass

func test2():
	print("tytyty")
	
func _physics_process(delta):
	var friction = false
	motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right_" +  id):
		motion.x = min(motion.x + ACCELERARION, MAX_SPEED)
	elif Input.is_action_pressed("ui_left_" + id):
		motion.x = max(motion.x - ACCELERARION, -MAX_SPEED)
	else:
		$AnimatedSprite.play("Idle")
		friction = true
	
	if is_on_floor():
		if Input.is_action_pressed("ui_up_" + id):
			motion.y = JUMP_WEIGHT
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.2)
	else:
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)
	
	
	motion = move_and_slide(motion, UP)
	
	_onPlayerCollides()
	_deathWith("Spike")
	_getDesease()
	
	pass

func _onPlayerCollides():
	for i in get_slide_count():
    	currentCollider = get_slide_collision(i).collider.name	

func _deathWith(killer):
	if currentCollider == killer:
		queue_free()

func _getDesease():
	if currentCollider == "Desease":
		GRAVITY = 20
		ACCELERARION = 10
		MAX_SPEED = 80
		JUMP_WEIGHT = -700
