class_name Player extends Node

export var id:int = 0
export var nickname:String = 'Default'

var Status = preload("res://src/status.gd")
var body_class = preload("res://src/body.gd")


export var status:GDScript = Status.new()

#Romnal estoy voalo ayudame aaamiiigg....  
func _init():
	var body = body_class.new()
	add_child(body)