extends AudioStreamPlayer
class_name CustomAudioStreamPlayer

var se_id: SoundEffect.id
var number: int

func _ready():
	finished.connect(queue_free)


func _on_kill(id: SoundEffect.id, rolling_number):
	if id != se_id:
		return
	elif number == rolling_number:
		#print("SPIKE PREVENTION")
		queue_free()