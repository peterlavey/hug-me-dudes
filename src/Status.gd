extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var _health:int = 0 
#export var _isDead:bool = setget set_isDead, get_isDead
#export var _isAlive:bool = setget set_isAlive, get_isAlive


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_health(health: int) -> void:
	_health = health

func get_health() -> int:
	return _health

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
