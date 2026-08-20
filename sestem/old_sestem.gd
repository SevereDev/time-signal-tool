extends Node
class_name OldSestem

@export var slog_brackets: Brackets = Brackets.SQUARE

@export var root_path:="user://"

@export var dump_folder:="user://dumps/"
@export var backup_folder:="user://backups/"
@export var ses_log_folder:="user://ses_library_logs/"
@export var save_folder:="user://saves/"
@export var settings_folder:="user://settings/"


enum Brackets {ROUND, SQUARE, CURLY,
}

enum TextColor {WHITE, RED, YELLOW, GREEN, BLUE, PINK,
}#	Like traffic lights!(at first)

enum SettingCategory {GAME, VIDEO, SOUND, CONTROLS,
}

enum SettingType {
	CHECKBOX, SLIDER, DROPDOWN,
}

enum CommandArgumentQuantity{NOT_ACCEPTED, REQUIRED, OPTIONAL,
}


signal console_print
signal console_new_line

#S3T (Severi's shitty signal terminal):
signal s3t
var s3t_history: Array[LogEntry]
#/

var command_directories: Dictionary[String, Dictionary]


func init_file_paths():
	init_path(dump_folder)
	init_path(backup_folder)
	init_path(ses_log_folder)
	init_path(save_folder)
	init_path(settings_folder)



func init_path(path: String):
	if not DirAccess.dir_exists_absolute(path):
		var error = DirAccess.make_dir_recursive_absolute(path)
		if error != OK:
			print("FUCK")
			crash_the_fucking_game()
		else:
			slog(3, "Sestem", "Created directory at path: ", path)
			




func _ready():
	init_file_paths()
	s3t.connect(_on_s3t_signal)
	add_system_commands()


func _console_connected():
	command_sestem_help()
	

func add_system_commands():
	add_command("root", "echo", "command_echo", 1, "Echoes back all arguments given to it.")
	add_command("root", "ls", "command_list_commands", 0, "Lists all available commands in a directory.")
	add_command("root", "dir", "command_list_directories", -1, "Lists available directories.")
	add_command("root", "ex", "command_run_expression", 1, "Standard Godot expression functionality.")
	add_command("s3t", "help", "command_s3t_help", -1, "Provides basic introduction for the s3t signal system.")
	add_command("s3t", "emit", "command_s3t_emit", 1, "Emits the s3t-signal with given paramenters packed in a PackedStringArray.")
	add_command("s3t", "log", "command_s3t_history", -1, "Shows previous s3t-signal events.")
	add_command("root", "quit", "quit_game", -1, "Closes the game.")
	add_command("s3t", "save", "command_save_s3t_history", -1, "Saves the signal history into a text file.")
	add_command("root", "help", "command_sestem_help", -1, "Gives the basic instructions to help you get started.")
	add_command("root", "manual", "command_sestem_manual", -1, "Provides more detailed instructions for using the developer console.")

func command_sestem_help():
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


func crash_the_fucking_game():
	get_tree().quit()

func quit_game():
	get_tree().quit()


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
	var signal_entry: LogEntry = create_log_entry(LogEntry.ClassificationType.EVENT, "Signal emitted", info)
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
	new_line_to_console()
	var cmd_array: Array = directory.values()
	sort_resources_by_string(cmd_array, "command_name")
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




func create_table_from_res_array(columns: int, list: Array, variable_names: PackedStringArray):
	var table_size = str(columns)
	var table: String = "[table="+table_size+"]"

	for r in list:
		for i in columns:
			var variable_data = str(r.get(variable_names[i]))
			table = table + "[cell]"+str(variable_data)+"[/cell]"
	table = table+"[/table]"

	return table


func command_list_directories():
	var dir_list = sort_alphabetically(command_directories.keys())
	print_to_console("Available directories:")
	new_line_to_console()
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


func add_command(directory_name: String, command_name: String, callable_name: String, argument_count: int, description:= "No description available.", source = self):#	Self ei välttämättä ole function kutsuja vaan Sestem. Ota selvää.
	if directory_name == "":
		slog(1, "Sestem", "Error adding command '", command_name, "'. Directory cannot be an empty string. Use 'root' for direct access.")
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


func create_log_entry(classification: LogEntry.ClassificationType, id: String, info: String = "No information available.", additional_data: Array = []):
	var log_entry = LogEntry.new()
	log_entry.classification = classification
	log_entry.id = id
	log_entry.info = info
	log_entry.additional_data = additional_data
	return log_entry


func create_log_file(log_array: Array[LogEntry]):
	var log_file_text:=""
	for l in log_array:
		log_file_text = log_file_text + l.convert_to_string()+"\n"

	return log_file_text


func slog(color:int, source_name: String, data_1 = "", data_2 = "", data_3 = "", data_4 = "", data_5 = ""):
	var bracketed_source
	match slog_brackets:
		Brackets.ROUND:
			bracketed_source = "(" + source_name + ")"
		Brackets.SQUARE:
			bracketed_source = "[" + source_name + "]"
		Brackets.CURLY:
			bracketed_source = "{" + source_name + "}"

	var result = colorize_text(bracketed_source, color)
	var text_array:= [result, " ", data_1, data_2, data_3, data_4, data_5] 
	var final_print = "".join(text_array)
	print_rich(final_print)
	print_to_console(final_print)


func colorize_text(text:String, color:int):
	var color_start := "[color=white]"
	var color_end := "[/color]"
	match color:
		TextColor.WHITE:
			color_start = "[color=white]"
		TextColor.RED:
			color_start = "[color=red]"
		TextColor.YELLOW:
			color_start = "[color=yellow]"
		TextColor.GREEN:
			color_start = "[color=green]"
		TextColor.BLUE:
			color_start = "[color=blue]"
		TextColor.PINK:
			color_start = "[color=pink]"
		_:
			color_start = "[color=white]"

	var colorized_text = color_start + text + color_end
	return colorized_text


func colorize_text_rgb(text: String, r: int, g: int, b: int):
	var color = Color8(r,g,b)
	var color_hex = color.to_html(false)
	var colorized_text = "[color=#" + color_hex + "]" + text + "[/color]"
	return colorized_text


func print_color(color:int, text: String):
	var result = colorize_text(text, color)
	print(result)


func generate_name_based_on_datetime(command_name:String, space:=""):
	var dt = get_datetime_string_formatted()
	var unique_name = command_name + space + dt + ".txt"
	return unique_name


func create_dump_file(text:=""):
	var command_name = generate_name_based_on_datetime("DUMP")
	change_or_create_folder("dumps")
	var path = root_path +"dumps/"+ command_name
	create_text_file(path, text)	


func change_or_create_folder(folder_name:String):
	var folder = DirAccess.open(root_path + folder_name)
	if folder != null:
		return folder
	else:
		folder = DirAccess.make_dir_absolute(root_path + folder_name)
		return folder


#	MUUTA TOI WAIT_SECONDS
#	JA SIT VOI KANS OLLA WAIT MINUTES
#	TAI HOURS
#	DAYS
#	UNTIL FURTHER NOTICE
func wait(seconds:float):
	await get_tree().create_timer(seconds).timeout


func create_text_file(file_path:String, data: String):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		slog(1, "Sestem", "Error at create_text_file():", file_path, "was null")
		return 1
	if data is String:
		file.store_string(data)
		return 0
	else:
		slog(1, "Failed to create text file: parameter 'data' needs to be String")
		return 1



func _create_backup(data, original_path):
	var basename = original_path.get_basename()
	var extension = original_path.get_extension()
	var dt = get_datetime_string_formatted()
	var filename = basename + "_" + dt + extension
	var new_path = backup_folder + filename
	
	return _save_json(data, new_path)


func _save_json(data, path: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		printerr("JSON save error")
		return false

	if data is String:
		file.store_string(data)
	else:
		file.store_string(JSON.stringify(data, "\t"))	#	 "\t" means pretty! -Eli siis formatoi jsonin rivit nätiksi
	#	file.store_string(data)	#

	file.close()
	return true
	


func save_json_to_folder(data, folder_path, file_name):
	var path = folder_path + file_name
	return _save_json(data, path)



func load_json(path):
	if not FileAccess.file_exists(path):
		printerr("JSON load error: file not found. Path: ", path)
		return null

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		printerr( "JSON load error: File failed to open: ", file)
		return null

	var content := file.get_as_text()
	file.close()

	var result = JSON.parse_string(content)
	if result == null:
		printerr("JSON parse error at: ", path)
		_create_backup(content, path)
		return null
	return result



func get_datetime_string_formatted(utc: bool = false):
	var dt = Time.get_datetime_dict_from_system(utc)
	var dt_str: String = "%04d-%02d-%02dT%02d-%02d-%02d" % [
		dt.year, dt.month, dt.day,	dt.hour, dt.minute, dt.second
	]
	return dt_str



func load_json_from_folder(folder_path, file_name):
	var path = folder_path + file_name
	return load_json(path)



func save_text_file(file_name:String, text: String, path: String = root_path):
	var full_path = path.path_join(file_name)
	var split = full_path.split(".", false, 2)

	if split.size() == 2:
		full_path = split[0] + ".txt"
	else:
		full_path = full_path + ".txt"

	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file == null:
		slog(1, "Sestem", "Error saving text file: Could not open path ", full_path, " for writing.")
		return false
	file.store_string(text)
	file.close()
	return true


func json_to_dict(json_string):
	var data = JSON.parse_string(json_string)
	
	if data == null:
		slog(1, "SESTEM", "JSON parse failed. Aborting.")
		return
	if typeof(data) == TYPE_DICTIONARY:
		return data
	else:
		slog(1, "SESTEM", "Wrong variable type sorry lol")

"""
func dict_to_binary(dict: Dictionary):
	return dict
"""


func sort_alphabetically(list: Array, order: bool = true):
	var sorted_list = list.duplicate()
	if order == true:
		sorted_list.sort_custom(func(a,b): return a.casecmp_to(b) < 0)
		return sorted_list
	else:
		sorted_list.sort_custom(func(a,b): return a.casecmp_to(b) > 0)
		return sorted_list


func sort_alphabetically_case_sensitive(list: Array, order: bool = true):
	var sorted_list = list.duplicate()
	sorted_list.sort()
	if order == false:
		sorted_list.reverse()
	return sorted_list


func sort_resources_by_string(list: Array, property_name: String, order:= true):
	var sorted_list = list.duplicate()
	if order == true:
		sorted_list.sort_custom(func(a,b):
			return a.get(property_name).casecmp_to(b.get(property_name)) < 0)
		return sorted_list
	else:
		sorted_list.sort_custom(func(a,b):
			return a.get(property_name).casecmp_to(b.get(property_name)) > 0)
		return sorted_list
