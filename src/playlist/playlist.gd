class_name Playlist extends Node

var musicPlayer: MusicPlayer = load("res://src/playlist/musicPlayer.gd").new()
var folderManager = load("res://src/utils/folderManager.gd").new()

func _init() -> void:
	musicPlayer.shuffle = true
	musicPlayer.set_songs(get_songs())
	add_child(musicPlayer)

func get_songs() -> Array:
	return folderManager.get_directory_list("res://sounds/ost", "ogg")

func play() -> void:
	musicPlayer.start()