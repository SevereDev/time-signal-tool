extends AudioStreamPlayer2D
class_name CustomAudioStreamPlayer2D

var se_id: SoundEffect.id
var number: int

func _ready():
	finished.connect(queue_free)

func print_number():
	print(number)
	


func _on_kill(id: SoundEffect.id, rolling_number):
	if id != se_id:
		return
	elif number == rolling_number:
		#print("2D SPIKE PREVENTION")
		queue_free()