extends Node

#@onready var Main = $self
#@onready var GameplayLayer = $%World2D
#@onready var GuiLayer = $%UiEnvironment
#@onready var menu_manager = $%MenuManager

var main
var GameplayLayer
var GuiLayer
var menu_manager

var uses_signals = true
var thread: Thread

var loaded_resource: PackedScene = null

var source_id = "Main"

#var menu_array = Index.menus.keys()
#@export var base_menu: int = []



func _ready():
	main = self
	GameplayLayer = $GameplayLayer
	GuiLayer = $GuiLayer
	#menu_manager = $%MenuManager

	GuiLayer.mouse_filter = Control.MOUSE_FILTER_IGNORE
#	menu_manager.mouse_filter = Control.MOUSE_FILTER_IGNORE
	load_menu("test_menu")



func change_level(level_path: String):
	var loaded_level = _load_scene(level_path)
	get_tree().change_scene_to_packed(loaded_level)



func load_level(level_name: String):
	var level_path = Index.fetch(Index.LEVELS, level_name)
	if level_path is not String:
		Ses.out(self, Color.RED, "Error loading level: '", level_name, "' was not found in the index.")
		return null
	var level_scene = _load_scene(level_path)
	if level_scene == null:
		return
	clear_all()
	var level_instance = level_scene.instantiate()
	GameplayLayer.add_child(level_instance)



func load_menu(menu_name: String):
	var menu_path = Index.fetch(Index.MENUS, menu_name)
	if menu_path is not String:
		Ses.out(self, Color.RED, "Error loading menu: '", menu_name, "' was not found in the index.")
		return null
	var menu_scene = _load_scene(menu_path)
	if menu_scene == null:
		return
	clear_all()
	var menu_instance = menu_scene.instantiate()
	GuiLayer.add_child(menu_instance)



func _load_scene(scene_path):
	if scene_path is not String:
		Ses.out(self, Color.RED, "Error loading scene: Invalid path type. Expected String. It is likely that the fetched scene wasn't found in the index.")
		return null
	var scene
	if scene_path != null:
		scene = load(scene_path)
	else:
		Ses.out(self, Color.RED, "Error loading scene: path '", scene_path, "' is not valid." )
		return
	if scene is PackedScene:
		return scene
	else:
		return null



func clear_current_level():
	for child in GameplayLayer.get_children():
		child.queue_free()



func clear_current_menu():
	for element in GuiLayer.get_children():
		element.queue_free()



func clear_all():
	clear_current_level()
	clear_current_menu()



func on_command_signal(id, command, data):
	match id:
		"Main":
			match command:
				"load_level":
					load_level(data)
				"load_menu":
					load_menu(data)
