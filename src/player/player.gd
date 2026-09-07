class_name Player extends CharacterBody2D

const UP = Vector2(0, -1)
var GRAVITY = 20
var ACCELERARION = 50
var MAX_SPEED = 200
var JUMP_WEIGHT = -550

var motion = Vector2()
var collision:CollisionShape2D
var currentCollider
var _animation:AnimatedSprite2D = AnimatedSprite2D.new()
var disease: Disease
var DiseaseFactory = load("res://src/disease/diseaseFactory.gd").new()
var CONSTANTS = load("res://src/player/constants.gd").new()

@export var _id: int = 1
@export var status: GDScript = load("res://src/player/status.gd").new()
@export var nickname: String = 'Default'
@export var character: PackedScene
@export var can_move: bool = true

var isKicking: bool = false

signal on_died
signal on_infected(player: CharacterBody2D, disease: Disease)
signal on_cured(player: CharacterBody2D)

func set_disease(_disease: Disease) -> void:
	if not status.isAlive:
		return
	disease = _disease
	status.isAfflicted = true
	disease.afflicted = self

	add_child(disease)
	emit_signal("on_infected", self, disease)

func _ready():
	load_texture()
	config_collision()
	add_to_group("players")
	
	pass

func config_collision() -> void:
	collision = CollisionShape2D.new()
	collision.shape = RectangleShape2D.new()

	set_collision(CONSTANTS.COLLISION_STATES.INITIAL)
	
	add_child(collision)

func set_collision(collisionState) -> void:
	if collision and collision.shape is RectangleShape2D:
		collision.shape.size = collisionState.SIZE * 2.0
		collision.position = Vector2(collisionState.POSITION.X, collisionState.POSITION.Y)

func _physics_process(delta):
	if status.isAlive:
		if can_move:
			movements()
			on_player_collides()
		else:
			_idle_physics()
	else:
		_dead_physics()
	
	pass

func _dead_physics() -> void:
	motion.y += GRAVITY
	if is_on_floor():
		motion.x = lerp(motion.x, 0.0, 0.2)
	else:
		motion.x = lerp(motion.x, 0.0, 0.05)
	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity

func _idle_physics() -> void:
	motion.y += GRAVITY
	motion.x = lerp(motion.x, 0.0, 0.2)
	if not isKicking:
		_animation.play("Idle")
	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity

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
			motion.x = lerp(motion.x, 0.0, 0.2)
	else:
		if friction == true:
			motion.x = lerp(motion.x, 0.0, 0.05)
	
	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity

func on_player_collides():
	for i in get_slide_collision_count():
		currentCollider = get_slide_collision(i).get_collider()

		if currentCollider and currentCollider.is_in_group("players"):
			var is_target_alive: bool = true
			if "status" in currentCollider and currentCollider.status:
				if ("isAlive" in currentCollider.status and not currentCollider.status.isAlive) or ("isDead" in currentCollider.status and currentCollider.status.isDead):
					is_target_alive = false
			if status.isAfflicted and is_target_alive:
				infect()
			#elif isKicking:
			#	hurts()
		elif currentCollider and currentCollider.name == "Spike" && status.isAlive:
			dead()

func hurts():
	currentCollider.dead()

func cured():
	if disease:
		disease.remove_effects()
		if is_instance_valid(disease):
			disease.queue_free()
		disease = null
	status.isAfflicted = false
	emit_signal("on_cured", self)

func infect():
	if not currentCollider or not is_instance_valid(currentCollider):
		return
	if "status" in currentCollider and currentCollider.status:
		if ("isAlive" in currentCollider.status and not currentCollider.status.isAlive) or ("isDead" in currentCollider.status and currentCollider.status.isDead):
			return
	if not disease:
		return
	var _disease = DiseaseFactory.get_disease(disease._name)
	
	currentCollider.set_disease(_disease)
	
	cured()

func dead()-> void:
	status.isAlive = false
	status.isDead = true
	emit_signal("on_died", self)
	_animation.play("Dead")
	set_collision(CONSTANTS.COLLISION_STATES.DEAD)
	
	if status.isAfflicted:
		if disease and is_instance_valid(disease):
			disease.remove_time_left()
		emit_signal("on_cured", self)

func deathWith(killer):
	if currentCollider.name == killer:
		dead()

func load_texture() -> void:
	if character == null:
		if ResourceLoader.exists("res://src/characters/Character.tscn"):
			character = load("res://src/characters/Character.tscn")
		else:
			character = load("res://src/characters/Peter.tscn")
	_animation = character.instantiate()
	_animation.connect("animation_finished", Callable(self, "animation_finished"))
	add_child(_animation)

func set_texture(newTexture: PackedScene = null) -> void:
	if newTexture != null:
		character = newTexture
	if _animation != null and is_instance_valid(_animation):
		_animation.queue_free()
	load_texture()

func animation_finished() -> void:
	if _animation.animation == 'Kick':
		isKicking = false
	elif _animation.animation == 'Dead':
		_animation.speed_scale *= 0.9
