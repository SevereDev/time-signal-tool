extends SesLibrary
class_name Sestem

var source_id = "Sestem"

#enum CommandArgumentQuantity{NOT_ACCEPTED, REQUIRED, OPTIONAL,}


#S3T (Severi's shitty signal terminal):
signal s3t
signal console_print
signal console_new_line

var ses_out_log: Array[LogEntry]
var s3t_history: Array[LogEntry]
#/

var command_directories: Dictionary[String, Dictionary]
var command_suggestions: Array

@export var default_settings: SettingsList
var settings: SettingsList
var rng = RandomNumberGenerator.new()


func _init():
	init_file_paths()

func _ready():
	s3t.connect(_on_s3t_signal)
	add_system_commands()
	init_settings()
	sestem_ready = true

func init_file_paths():
	init_path(ses_log_folder)
	init_path(backup_folder)
	init_path(dump_folder)
	init_path(save_folder)
	init_path(settings_folder)
	init_path(test_folder)


func init_path(path: String):
	if not DirAccess.dir_exists_absolute(path):
		var error = DirAccess.make_dir_recursive_absolute(path)
		if error != OK:
			print("FUCK")
			quit_game()
		else:
			out(self, Color.WHITE, "Created directory at path: ", path)

"""
func update_command_suggestion_array():#	Vois toimia esim aina kun avaa konsolin
	var directories: Array
	directories = command_directories.keys()
		var command_name: String = command_directories[key].command_name
		#var dir_name: String
		var suggestion: String
		if key == "root":
			suggestion = command_name
		else:	
			suggestion = str(key)+ "."+ command_name 
		command_suggestions.append(suggestion)


func get_command_suggestions(input_text: String = "", amount: int = 5):
	#	Tee array
	#	Lisää haluttu määrä vaihtoehtoja rootista ja directoryista
	#	Tarkkuusjärjestyksessä, muuten aakkos
	var given_suggestions: Array
	if input_text != "":
		for s in command_suggestions:
			if input_text in command_suggestions[s]:
				given_suggestions.append(s)
	var sorted_suggestions = sort_alphabetically(given_suggestions)
	return sorted_suggestions
"""



#	Suggestion-listan eka versio, hyvin simppeli:

func simple_sugg(input_text: String = ""):
	if input_text == "":
		return
	var root_directory = command_directories["root"]
	var available_commands = root_directory.keys()
	for key in available_commands:
		var command_name: String = command_directories[key].command_name
		#var dir_name: String
		var suggestion: String
		if key == "root":
			suggestion = command_name



func _console_connected():
	pass


func init_settings():
	settings = default_settings.duplicate()
	var result = load_settings()
	if result == false:
		save_settings()


func save_settings():
	var exported_settings = settings.export()
	var result = save_as_binary("game_settings", exported_settings, folder.SETTINGS)
	if result == true:
		print_to_console("Settings saved")
	else:
		out(self, Color.RED, "Failed to save settings")


func load_settings():
	var imported_settings = load_file("game_settings", folder.SETTINGS)
	if imported_settings:
		settings.import(imported_settings)
		print_to_console("Settings loaded")
		command_list_settings()
		return true
	else:
		out(self, Color.WHITE, "No settings file was found. Creating one...")
		return false


	

func command_list_settings():
	var settings_array: Array
	var settings_dict = settings.export()
	var settings_keys = settings_dict.keys()
	for k in settings_keys:
		var value_array: Array = [k, str(settings_dict[k])]
		settings_array.append(value_array)
	print_to_console("Current settings in memory:")
	print_to_console(create_table_from_nested_array(2, settings_array, 8))


func command_edit_setting(arguments: PackedStringArray):
	var settings_dict = settings.export()
	#var selected_setting = settings_dict.get(arguments[0])
	if settings_dict.has(arguments[0]):
		var new_value = match_type_strict(arguments[1], typeof(settings_dict[arguments[0]]))
		settings_dict.set(arguments[0], new_value)
		print_to_console(arguments[0]+" set to " + str(new_value))
	settings.import(settings_dict)


func reset_settings_to_defaults():
	settings = default_settings.duplicate()
	print_to_console("Settings reset to defaults.")

func match_type_strict(text:String, type:int):
	var result
	match type:
		TYPE_STRING:
			pass
		TYPE_INT:
			if text.is_valid_int():
				result = text.to_int()
				return result
			else:
				return null
		TYPE_FLOAT:
			if text.is_valid_float():
				result = text.to_float()
				return result
			else:
				return null
		TYPE_BOOL:
			match text:
				"1":
					result = true
					return result
				"true":
					result = true
					return result
				"0":
					result = false
					return result
				"false":
					result = false
					return result
				_:
					return null
		_:
			return null


# -1 = Never takes any arguments
# 0 = Optional arguments. NOTE: ASSIGNED FUNCTION MUST ALWAYS STILL TAKE A PACKED STRING ARRAY AS ARGUMENT!
# 1 and up = Minimum arguments

func add_system_commands():
#	add_command(self, "root", "echo", "command_echo", 1, "Echoes back all arguments given to it.")
	add_command(self, "root", "ls", "command_list_commands", 0, "Lists all available commands in a directory")
#	add_command(self, "root", "dir", "command_list_directories", -1, "Lists available directories.")
#	add_command(self, "root", "ex", "command_run_expression", 1, "Standard Godot expression functionality.")
#	add_command(self, "s3t", "help", "command_s3t_help", -1, "Provides basic introduction for the s3t signal system.")
#	add_command(self, "s3t", "emit", "command_s3t_emit", 1, "Emits the s3t-signal with given paramenters packed in a PackedStringArray.")
#	add_command(self, "s3t", "log", "command_s3t_history", -1, "Shows previous s3t-signal events.")
	add_command(self, "root", "quit", "quit_game", -1, "Closes the program")
	#add_command(self, "s3t", "save", "command_save_s3t_history", -1, "Saves the signal history into a text file.")
	#add_command(self, "root", "help", "command_sestem_help", -1, "Gives the basic instructions to help you get started")
#	add_command(self, "root", "manual", "command_sestem_manual", -1, "Provides more detailed instructions for using the developer console.")
#	add_command(self, "settings", "ls", "command_list_settings", -1, "Lists all available game settings.")
#	add_command(self, "settings", "edit", "command_edit_setting", 2, "Edits selected setting.")
#	add_command(self, "settings", "save", "save_settings", -1, "Saves the current settings to disk.")
#	add_command(self, "settings", "load", "load_settings", -1, "Attempts to load settings from disk.")
#	add_command(self, "settings", "reset", "reset_settings_to_defaults", -1, "Resets settings to their default values.")

func _command_sestem_help():
	print_to_console("Type 'ls' to see available commands in a directory.")
	print_to_console("Type 'dir to see available directories.'")
	print_to_console("Type 'manual' for more information.")
	print_to_console("Type 'help' to see this text again.")





func command_sestem_manual():
	print_to_console("[b]SES-library developer console[/b]")
	new_line_to_console()
	print_to_console("Commands are stored in directories. Directories are specified by using '.' before the command like this:")
	print_to_console("'directory.command'")
	new_line_to_console()
	print_to_console("Just typing 'command' without specifying directory will search the root directory:")
	print_to_console("'command' is the same as 'root.command'")
	new_line_to_console()
	print_to_console("Arguments are split by using spaces:")
	print_to_console("'category.command argument1 argument2'")

func save_log_as_text(file_name: String, log_array: Array[LogEntry], path = ses_log_folder):
	var file = create_log_file(log_array)
	save_text_file(file_name	, file, path)


func command_s3t_help():
	new_line_to_console()
	print_to_console("[b]S3T: Severi's Shitty Signal Terminal[/b]")
	print_to_console("Remnant of the original SignalManager from SES-library 0.1.")
	print_to_console("The lazy man's way to create commands. Just connect your node to Sestem's s3t -signal and pass any String-based information through the arguments-array!")
	print_to_console("You can send data, determine intended recipients and even pass the most complex instructions, which you can then parse using if- and match-statements! (oh god...)")
	print_to_console("Use with caution! Identifying destinations and commands purely by using strings can get out of hand REAL fast.")


func command_s3t_emit(arguments: PackedStringArray):
	s3t.emit(arguments)


func _on_s3t_signal(arguments: PackedStringArray):
	var info= str(arguments)
	var signal_entry: LogEntry = create_log_entry(LogEntry.ClassificationType.MESSAGE, "Signal emitted", info)
	s3t_history.append(signal_entry)


func command_s3t_history():
	var variable_names = ["id", "info", "timestamp"]
	var table: String = create_table_from_res_array(3, s3t_history, variable_names)
	print_to_console(table)


func command_save_s3t_history():
	var timestamp = get_datetime_string_formatted()
	save_log_as_text("s3t_log"+timestamp, s3t_history)


func command_run_expression(arguments: PackedStringArray):
	var text = " ".join(arguments)
	print_to_console(text)
	var expression = Expression.new()
	var error = expression.parse(text)
	if error != OK:
		print_to_console(expression.get_error_text())
		return
	var result = expression.execute()
	if not expression.has_execute_failed():
		print_to_console(str(result))


func command_list_commands(arguments: PackedStringArray):
	var directory_name
	if arguments.size() == 0:
		directory_name = "root"
	else:
		directory_name = arguments[0]
	if command_directories.has(directory_name) == false:
		print_to_console("Could not find directory: '", directory_name, "'")
		return
	var directory: Dictionary = command_directories.get(directory_name)
	if directory == null:
		print_to_console("Could not find directory: '", directory_name, "'")
		return
	print_to_console("Commands in '", directory_name, "':")
	#new_line_to_console()
	var cmd_array: Array = directory.values()
	sort_resources_by_string_var(cmd_array, "command_name")
	var column1: PackedStringArray
	var column2: PackedStringArray

	for c in cmd_array:
		column1.append(c.command_name)
		column2.append(c.description)
	var table = create_table(column1, column2)
	print_to_console(table)


func create_table(column1: PackedStringArray, column2: PackedStringArray):
	var table: String = "[table=2]"
	for i in column1.size():
		table = table + "[cell]"+ column1[i] +"[/cell]" + "[cell]     - " + column2[i] + "[/cell]"

	table = table + "[/table]"
	return table




func command_list_directories():
	var dir_list = sort_alphabetically(command_directories.keys())
	print_to_console("Available directories:")
	for i in dir_list: 
		print_to_console(i)


func command_echo(words: PackedStringArray):
	var text = " ".join(words)
	print_to_console(text)


func print_to_console(a:="",b:="",c:="",d:="",e:="",f:="",g:="",h:="",i:="",j:="",k:="",l:="",m:="",n:=""):
	console_print.emit(a,b,c,d,e,f,g,h,i,j,k,l,m,n)

func new_line_to_console():
	console_new_line.emit()


func print_array_to_console(words: PackedStringArray):
	var text = " ".join(words)
	console_print.emit(text)


func create_command(command_name: String, callable_name: String, argument_count: int, description: String, source):#	Self ei välttämättä ole function kutsuja vaan Sestem. Ota selvää. Pitäis olla ok t. Gemini
	var callable = Callable(source, callable_name)
	var new_command:= Command.new()
	new_command.command_name = command_name
	new_command.command_callable = callable
	new_command.minimum_arguments = argument_count
	new_command.description = description
	return new_command


func add_command(source, directory_name: String, command_name: String, callable_name: String, argument_count: int, description:= "No description available."):
	if directory_name == "":
		out(self, Color.RED, "Error adding command '", command_name, "'. Directory cannot be an empty string. Use 'root' for direct access.")
		return false
	if !command_directories.has(directory_name):
		var dict: Dictionary
		var directory_creation_result = command_directories.set(directory_name, dict)
		if directory_creation_result == false:
			return false
	var cmd = create_command(command_name, callable_name, argument_count, description, source)
	var command_creation_result = command_directories[directory_name].set(command_name, cmd)
	if command_creation_result == false:
		return false
	var command_res = command_directories[directory_name][command_name]
	if command_res is Command:
		return true
	else:
		return false


func remove_command(directory_name: String, command_name: String):
	var cat = command_directories.get(directory_name)
	cat.erase(command_name)


func remove_directory(directory_name: String):
	command_directories.erase(directory_name)


func _parse_command(text: String):
	var directory_name: String
	var command_name: String
	var arguments: PackedStringArray

	var directory_split: Array = text.split(".", false, 2)
	var argument_split: Array = text.split(" ", false)
		
	match directory_split.size():
		1:
			directory_name = ""
			command_name = argument_split[0]
		2:
			directory_name = directory_split[0]
			var name_split: Array = directory_split[1].split(" ", true) 
			command_name = name_split[0]

	argument_split.remove_at(0)
	arguments = argument_split
	var parsed_command: Array = [directory_name, command_name, arguments]
	return parsed_command


func parse_command(text: String):
	var directory_name: String
	var command_name: String
	var arguments: PackedStringArray

	var spacebar_split: Array = text.split(" ", false)
	var category_split: Array = spacebar_split[0].split(".", false)

	match category_split.size():
		1:
			directory_name = "root"
			command_name = category_split[0]
		2:
			directory_name = category_split[0]
			command_name = category_split[1]
		_:
			print_to_console("Parse error: Nested dictionaries are not supported. Keep it at one dot, champ.")
			return null
	spacebar_split.remove_at(0)
	arguments = spacebar_split
	var parsed_command: Array = [directory_name, command_name, arguments]
	return parsed_command


func _execute_parsed_command(parsed_command: Array):
	var directory_name = parsed_command[0]
	var command_name = parsed_command[1]
	var arguments = parsed_command[2]

	if directory_name == "":
		directory_name = "root"
	var command = _get_command(directory_name, command_name)

	if command is not Command:
		return null

	command.run(arguments)


func execute_command(text: String):
	var parsed_command = parse_command(text)
	if parsed_command is Array:
		_execute_parsed_command(parsed_command)
	else:
		return null


func _get_command(directory_name: String, command_name: String):
	var directory
	var command
	if command_directories.has(directory_name) == false:
		print_to_console("Could not find directory: '"+ directory_name+ "'. Type 'dir' do list directories.")
		return null

	directory = command_directories.get(directory_name)
	if directory.has(command_name) == false:
		print_to_console("Could not find : '"+ command_name+ "' in '"+directory_name+"'")
		return null

	command = directory.get(command_name)
	if command == null:
		return null

	return command
