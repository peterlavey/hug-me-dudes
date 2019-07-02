extends KinematicBody2D

const UP = Vector2(0, -1)
var GRAVITY = 20
var ACCELERARION = 50
var MAX_SPEED = 200
var JUMP_WEIGHT = -550

var motion = Vector2()
var currentCollider = ""

export var animation:PackedScene
var _animation:AnimatedSprite = AnimatedSprite.new()

export var _id:int = 1
export var id = "1"

func _ready():
	load_texture()
	add_to_group("players")
	
	pass
	
func _physics_process(delta):
	var friction = false
	motion.y += GRAVITY
	
	if Input.is_action_pressed("ui_right_" + str(_id)):
		motion.x = min(motion.x + ACCELERARION, MAX_SPEED)
		_animation.play("Run")
		_animation.flip_h = false
	elif Input.is_action_pressed("ui_left_" + str(_id)):
		motion.x = max(motion.x - ACCELERARION, -MAX_SPEED)
		_animation.play("Run")
		_animation.flip_h = true
	else:
		friction = true
		_animation.play("Idle")
	
	if is_on_floor():
		if Input.is_action_pressed("ui_up_" + str(_id)):
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

func load_texture():
	_animation = animation.instance()
	add_child(_animation)

func set_texture(newTexture):
	_animation = animation.instance()
	add_child(_animation)
