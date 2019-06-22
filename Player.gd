extends "res://src/Status.gd"

export var _id:int = 0
export var _name:String = 'Default'

func _ready():
	pass

func set_name(name: String) -> void:
	_name = name

func get_name() -> String:
	return name
