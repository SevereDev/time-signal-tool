extends Resource
class_name SoundEffect



enum id {
REVOLVER_DEFAULT,
GUN_EMPTY,
}

@export_range(0, 10) var limit: int = 5
@export var selected_id: id
@export var sound_file: AudioStreamMP3
@export_range(-40, 20) var volume: float = 0
@export_range(0.0, 4.0,.01) var pitch_scale: float = 1.0
@export_range(0.0, 1.0,.01) var pitch_randomness: float = 0.0

