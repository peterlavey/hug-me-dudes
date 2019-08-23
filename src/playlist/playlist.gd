class_name Playlist extends Node

var musicPlayer = load("res://src/playlist/musicPlayer.gd").new()
var folderManager = load("res://src/utils/folderManager.gd").new()

func _init():
	musicPlayer.shuffle = true
	musicPlayer.set_songs(get_songs())
	
	add_child(musicPlayer)
	pass

func get_songs()-> Array:
	return folderManager.get_directory_list("res://sounds/ost", "ogg")

func play():
	musicPlayer.start()
	pass