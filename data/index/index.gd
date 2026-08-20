extends Node
class_name Index


enum {
	OBJECTS,
	WEAPONS,
	PROJECTILES,
	CHARACTERS,
	LEVELS,
	MENUS,
	TEST_DATA
}


static func get_dict(cat: int):
	match cat:
		OBJECTS:
			return objects
		WEAPONS:
			return weapons
		PROJECTILES:
			return projectiles
		CHARACTERS:
			return characters
		LEVELS:
			return levels
		MENUS:
			return menus
		TEST_DATA:
			return 
		_:	
			return null


static func fetch(cat: int, dict_key: String):
	var selected_dict = get_dict(cat).duplicate()
	if selected_dict is not Dictionary:
		return null
	if selected_dict.has(dict_key):
		var data = selected_dict.get(dict_key)
		if data is not String:
			return null
		else:
			return data
	else:
		return null

const levels: Dictionary = {}

const menus: Dictionary = {
	"test_menu": "res://scenes/gui/menus/test_menu.tscn",
	"null_menu": "not a real address",
}

const objects: Dictionary = {}

const characters: Dictionary = {}

const weapons: Dictionary = {}

const projectiles: Dictionary = {}



const test_data: Dictionary[String, String] = {
	"test_0": "res://scenes/gui/menus/test_menu.tscn",
	"test_1": "res://scenes/gui/menus/test_menu.tscn",
	"test_2": "res://scenes/gui/menus/test_menu.tscn",
	"test_3": "res://scenes/gui/menus/test_menu.tscn",
	"test_4": "res://scenes/gui/menus/test_menu.tscn",
	"test_5": "res://scenes/gui/menus/test_menu.tscn",
	"test_6": "res://scenes/gui/menus/test_menu.tscn",
	"test_7": "res://scenes/gui/menus/test_menu.tscn",
	"test_8": "res://scenes/gui/menus/test_menu.tscn",
	"test_9": "res://scenes/gui/menus/test_menu.tscn",
}
