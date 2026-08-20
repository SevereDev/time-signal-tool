extends Resource
class_name SettingsList

@export var fullscreen: bool = false

@export_range(0.0, 1.0) var master_volume: float = 0.5
@export_range(0.0, 1.0) var sfx_volume: float = 0.5
@export_range(0.0, 1.0) var music_volume: float = 0.5

@export var camera_follows_cursor: bool = true



func export():
	var exported_settings: Dictionary = {
		"fullscreen": fullscreen,
		"master_volume": master_volume,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume,
		"camera_follows_cursor": camera_follows_cursor
		}
	return exported_settings


func import(imported_settings: Dictionary):
	fullscreen = imported_settings["fullscreen"] 
	master_volume = imported_settings["master_volume"]
	sfx_volume = imported_settings["sfx_volume"]
	music_volume = imported_settings["music_volume"]
	camera_follows_cursor = imported_settings["camera_follows_cursor"]
