class_name Playlist extends Node

var MusicPlayer = load("res://src/playlist/musicPlayer.gd")
var musicPlayer
var folderManager = load("res://src/utils/folderManager.gd").new()

func _init():
	musicPlayer = MusicPlayer.new()
	musicPlayer.shuffle = true
	musicPlayer.set_songs(get_songs())
	add_child(musicPlayer)
	pass

func get_songs()-> Array:
	return folderManager.get_directory_list("res://sounds/ost", "ogg")

func play():
	musicPlayer.start()
	pass