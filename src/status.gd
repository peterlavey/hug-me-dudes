class_name Status extends GDScript

export var this = ''

export var health:int = 999
export var isDead:bool = false
export var isAlive:bool = true

func _ready():
	pass
	
func set_health(_health: int) -> void:
	this.health = _health

func get_health() -> int:
	return this.health
	
func set_isDead(_isDead: bool) -> void:
	this.isDead = _isDead

func get_isDead() -> bool:
	return this.isDead
	
func set_isAlive(_isAlive: bool) -> void:
	this.isAlive = _isAlive

func get_isAlive() -> bool:
	return this.isAlive	