extends Resource
class_name BackgroundMusic

enum id{
MAIN_MENU,
LEVEL_1,
}


func _ready() -> void:
	pass # Replace with function body.

@export var selected_id: id
@export var sound_file: AudioStreamMP3
@export_range(-40, 20) var volume: float = 0
@export_range(0.0, 4.0,.01) var pitch_scale: float = 1.0

