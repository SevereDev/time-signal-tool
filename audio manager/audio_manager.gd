extends Node2D

#	Original code by Aarimous. Heavily iterated by Severe Entertainment.

var sound_effect_dict: Dictionary = {} ## Loads all registered SoundEffects on ready as a reference.
var background_music_dict: Dictionary = {}
var background_sound_dict: Dictionary = {}

signal kill_audio_player

@export var sound_effects: Array[SoundEffect] ## Stores all possible SoundEffects that can be played.
@export var background_music: Array[BackgroundMusic]
@export var background_sounds: Array[BackgroundSound]

var rolling_numbers: Array[int]

func _ready() -> void:	# Tää tulee hajoo niin vitun kovaa
	for sound_effect: SoundEffect in sound_effects:
		sound_effect_dict[sound_effect.selected_id] = sound_effect
	for bgm: BackgroundMusic in background_music:
		background_music_dict[bgm.selected_id] = bgm
	for bgs: BackgroundSound in background_sounds:
		background_sound_dict[bgs.selected_id] = bgs


	init_rolling_numbers()

func init_rolling_numbers():
	rolling_numbers.resize(sound_effects.size())
	for sound_effect in sound_effects:
		rolling_numbers.set(sound_effect.selected_id, 0)


func roll_number(sound_effect: SoundEffect):
	var current_number = rolling_numbers[sound_effect.selected_id]
	var new_number = posmod(current_number + 1, sound_effect.limit)
	rolling_numbers[sound_effect.selected_id] = new_number
	return new_number


func spike_prevention(sound_effect: SoundEffect, number: int):
	kill_audio_player.emit(sound_effect.selected_id, number)


func play_se(se_id: SoundEffect.id, location = 0) -> void:
	if location is int and location == 0:
		_play_se_1d(se_id)
	elif location is Vector2:
		_play_se_2d(se_id, location)
	else:
		return


func bgm_play_track():

	pass


func bgm_queue_add():

	pass


func bgm_queue_clear():

	pass


func bgm_pause():

	pass


func bgm_resume():

	pass


func bgm_reset():

	pass


func _play_se_1d(se_id: SoundEffect.id) -> void:
	if sound_effect_dict.has(se_id):
		var sound_effect: SoundEffect = sound_effect_dict[se_id]
		var new_audio: CustomAudioStreamPlayer = CustomAudioStreamPlayer.new()
		add_child(new_audio)
		new_audio.stream = sound_effect.sound_file
		new_audio.volume_db = sound_effect.volume
		new_audio.pitch_scale = sound_effect.pitch_scale
		new_audio.pitch_scale += Ses.rng.randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness)
#		new_audio.finished.connect(new_audio.queue_free)
		var number = roll_number(sound_effect)
		new_audio.number = number
		spike_prevention(sound_effect, number)
		kill_audio_player.connect(new_audio._on_kill)
		new_audio.play()
	else:
		push_error("Audio Manager failed to find setting for se_id ", se_id)



func _play_se_2d(se_id: SoundEffect.id, location: Vector2) -> void:
	if sound_effect_dict.has(se_id):
		var sound_effect: SoundEffect = sound_effect_dict[se_id]
		var new_audio: AudioStreamPlayer2D = CustomAudioStreamPlayer2D.new()
		add_child(new_audio)
		new_audio.position = location
		new_audio.stream = sound_effect.sound_file
		new_audio.volume_db = sound_effect.volume
		new_audio.pitch_scale = sound_effect.pitch_scale
		new_audio.pitch_scale += Ses.rng.randf_range(-sound_effect.pitch_randomness, sound_effect.pitch_randomness)
		new_audio.finished.connect(new_audio.queue_free)
		var number = roll_number(sound_effect)
		new_audio.number = number
		spike_prevention(sound_effect, number)
		kill_audio_player.connect(new_audio._on_kill)
		new_audio.play()
	else:
		push_error("Audio Manager failed to find setting for id ", se_id)
