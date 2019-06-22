class_name Player extends Node

export var _id:int = 0
export var _name:String = 'Default'
export var _status = preload("res://src/status.tscn")

func _ready():
	_status = _status.instance()
	pass

func set_name(name: String) -> void:
	_name = name

func get_name() -> String:
	return name
	
func get_status():
	return _status	
