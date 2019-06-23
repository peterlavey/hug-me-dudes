class_name Player extends Node

var Body = preload("res://src/body.gd")

export var id:int = 0
export var nickname:String = 'Default'
var body:KinematicBody2D =  Body.new()


var Status = preload("res://src/status.gd")
var body_class = preload("res://src/body.gd")


export var status:GDScript = Status.new()

func _init():
	add_child(body)