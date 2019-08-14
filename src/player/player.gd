class_name Player extends KinematicBody2D

const UP = Vector2(0, -1)
var GRAVITY = 20
var ACCELERARION = 50
var MAX_SPEED = 200
var JUMP_WEIGHT = -550

var motion = Vector2()
var currentCollider
var _animation:AnimatedSprite = AnimatedSprite.new()
var disease:Node2D
var DiseaseFactory = load("res://src/disease/diseaseFactory.gd").new()

export var _id:int = 1
export var status:GDScript = load("res://src/player/status.gd").new()
export var nickname:String = 'Default'
export var character:PackedScene

var isKicking = false

signal on_died

func set_disease(_disease):
	disease = _disease
	status.isAfflicted = true
	disease.afflicted = self

	add_child(disease)

func _ready():
	load_texture()
	add_to_group("players")
	
	pass
	
func _physics_process(delta):
	if(status.isAlive):
		movements()
		on_player_collides()
	
	pass

func movements():
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
	#elif Input.is_action_pressed("ui_kick_" + str(_id)) && !isKicking:
	#	isKicking = true
	#	_animation.play("Kick")	
	elif !isKicking:
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

func on_player_collides():
	for i in get_slide_count():
		currentCollider = get_slide_collision(i).collider
		if currentCollider.name == "Player":
			if status.isAfflicted:
				infect()
			#elif isKicking:
			#	hurts()
		elif currentCollider.name == "Spike" && status.isAlive:
			dead()
func hurts():
	print("hurts")
	currentCollider.dead()

func cured():
	disease.remove_effects()
	status.isAfflicted = false
	disease.queue_free()
	pass

func infect():
	var _disease = DiseaseFactory.get_disease(disease._name)
	
	_disease.position.x = -20
	_disease.position.y = -150
	currentCollider.set_disease(_disease)
	
	cured()
	pass

func dead()-> void:
	status.isAlive = false
	emit_signal("on_died", self)
	_animation.play("Dead")

	#queue_free()

func deathWith(killer):
	if currentCollider.name == killer:
		dead()

func load_texture():
	_animation = character.instance()
	_animation.connect("animation_finished", self, "animation_finished")
	add_child(_animation)

func set_texture(newTexture):
	_animation = character.instance()
	add_child(_animation)

func animation_finished():
	if _animation.animation == 'Kick':
		isKicking = false
	elif _animation.animation == 'Dead':
		_animation.speed_scale *= 0.9
