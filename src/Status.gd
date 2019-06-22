class_name Status extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var _health:int = 0 
export var _isDead:bool = false
export var _isAlive:bool = true

func _ready():
	pass
	
func set_health(health: int) -> void:
	_health = health

func get_health() -> int:
	return _health
	
func set_isDead(isDead: bool) -> void:
	_isDead = isDead

func get_isDead() -> bool:
	return _isDead
	
func set_isAlive(isAlive: bool) -> void:
	_isAlive = isAlive

func get_isAlive() -> bool:
	return _isAlive	
