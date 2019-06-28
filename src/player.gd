class_name PlayerScript extends Node

#test
var Status = preload("res://src/status.gd")
var body = preload("res://characters/Player.tscn")

export onready var _id:int
export var nickname:String = 'Default'
export var status:GDScript = Status.new()
export var texture:StreamTexture

func _init():

	pass

func _ready():
	print(_id)
	
	body = body.instance()
	body._id = _id
	body.texture = texture

	add_child(body)