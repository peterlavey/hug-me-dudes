class_name MusicPlayer extends AudioStreamPlayer2D

export var songs: Array
export var shuffle: bool = true
export var currentSong: String
var currentIndex:int = 0
var input

func _init():
	#todo: no funciona el emit
	config_input()
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
	set_current_song()
	load_song()
	play(stream.get_length())
	verify_list()

func set_current_song():
	currentSong = songs[currentIndex]
	input.set_text(currentSong.split(".")[0])

func load_song():
	var song = load('res://sounds/ost/' + currentSong)
	stream = song

func verify_list():
	if currentIndex < songs.size() -1:
		currentIndex += 1
	else:
		currentIndex = 0

func config_input() -> void:
	input = TextEdit.new()
	input.rect_size.x = 500
	input.rect_size.y = 30
	
	add_child(input)
	
	pass

func _process(delta):
	if get_playback_position() > stream.get_length() -0.05:
		next_song()
	pass