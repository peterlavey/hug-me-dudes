class_name Player extends Node

export var _id:int = 0
export var _name:String = 'Default'
var _status = preload("res://src/Status.gd")

func _ready():
	_status = _status.instance()
	pass

func set_name(name: String) -> void:
	_name = name

func get_name() -> String:
	return name	
