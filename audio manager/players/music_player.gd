extends AudioStreamPlayer
class_name MusicPlayer


#	Sille soitettavalle äänelle on jo ihan varmasti oma variable

var queue: Array[BackgroundMusic]
var current_track: int = 0
var looping: bool = true


func _ready() -> void:
	finished.connect(next_track)


func next_track():
	if queue.size() == 0:
		stop()
		return
	var next_track_index = posmod(current_track + 1, queue.size())
	if next_track_index < current_track and looping == false:
		stop()
	else:
		current_track = next_track_index
		_play_track()


func _play_track():
	stream = queue[current_track].sound_file
	play()


func play_bgm(id: BackgroundMusic.id):
	clear_queue()


func clear_queue():
	queue = []
	


func reset():
	stop()


#	stream -variable meinaa soitettavaa asiaa
#	play() aloittaa soiton
#	stop() lopettaa