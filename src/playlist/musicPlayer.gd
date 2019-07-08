class_name MusicPlayer extends AudioStreamPlayer2D

export var songs: Array
export var shuffle: bool = true
export var currentSong: String
var currentIndex:int = 0

func _init():
	#todo: no funciona el emit
	connect("finished", self, "next_song")
	pass

func set_songs(_songs)-> void:
	songs = _songs
	if shuffle:
		songs.shuffle()

func next_song()-> void:
	stop()
	start()
	pass

func start():
	var song = load('res://sounds/ost/' + songs[currentIndex])
	stream = song
	play()
	
	if currentIndex < songs.size() -1:
		currentIndex += 1
	else:
		currentIndex = 0

func _process(delta):
	if get_playback_position() > stream.get_length() -0.05:
		next_song()
	pass