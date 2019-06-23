class_name Player extends Node

export var id:int = 0
export var nickname:String = 'Default'
export var Status = preload("res://src/status.gd")
var body_class = preload("res://src/body.gd")


export var status:GDScript = Status.new()

func _init():
	var body = body_class.new()
	add_child(body)

func _ready():
	pass

func set_nickname(_nickname: String) -> void:
	nickname = _nickname

func get_nickname() -> String:
	return nickname