class_name Player extends Node

export var id:int = 0
export var nickname:String = 'Default'
export var Status = preload("res://src/status.gd")
var spriteImage = preload("res://sprites/icon.png")	
var playerSprite = Sprite.new()


export var status:GDScript = Status.new()
#export var body:KinematicBody2D = Body.new()

func init_player():
	_load_texture()

func _ready():
	pass

func set_nickname(_nickname: String) -> void:
	nickname = _nickname

func get_nickname() -> String:
	return nickname
	
func _load_texture():
	add_child(playerSprite)
	playerSprite.set_texture(spriteImage)
	