extends Node
class_name SesLibrary


@export var slog_brackets: Brackets = Brackets.SQUARE

const root_path:="user://ses/"

const dump_folder:="user://ses/dumps/"
const backup_folder:="user://ses/backups/"
const ses_log_folder:="user://ses/sestem_logs/"
const save_folder:="user://ses/saves/"
const settings_folder:="user://ses/settings/"
const test_folder:="user://ses/tests"

const inherits_ses_library = true


enum folder{
	ROOT,
	LOGS,
	BACKUPS,
	DUMPS,
	SAVES,
	SETTINGS,
	TESTS

}

const folders:Array =[
	"user://ses/",
	"user://ses/sestem_logs/",
	"user://ses/backups/",
	"user://ses/dumps/",
	"user://ses/saves/",
	"user://ses/settings/",
	"user://ses/tests"
]

enum Brackets {ROUND, SQUARE, CURLY,
}

enum TextColor {WHITE, RED, YELLOW, GREEN, BLUE, PINK,
}#	Like traffic lights!(at first)

var sestem_ready:bool = false


#	Alkuun aina self. Pistä scripteihin source_id = "Lähteen nimi"
func out(source, color: Color = Color.WHITE, data_1 = "", data_2 = "", data_3 = "", data_4 = "", data_5 = ""):
	var source_name: String
	source_name = "Unknown"
	if "source_id" in source:
		source_name = source.source_id
	elif "inherits_ses_library" in source:
		source_name = "SesLibrary"
		#else vielä? vitun dementia
	var bracketed_source
	match slog_brackets:
		Brackets.ROUND:
			bracketed_source = "(" + source_name + ")"
		Brackets.SQUARE:
			bracketed_source = "[" + source_name + "]"
		Brackets.CURLY:
			bracketed_source = "{" + source_name + "}"

	var colorized_name = colorize_text(bracketed_source, color)
	var text_array:= [colorized_name, " ", data_1, data_2, data_3, data_4, data_5] 
	var final_print = "".join(text_array)
	print_rich(final_print)
	if sestem_ready == true:
		Ses.print_to_console(final_print)
		Ses.ses_out_log.append(create_log_entry(LogEntry.ClassificationType.MESSAGE, final_print, ""))



func save_log_as_text(file_name: String, log_array: Array[LogEntry], path = ses_log_folder):
	var file = create_log_file(log_array)
	save_text_file(file_name, file, path)


func quit_game():
	get_tree().quit()




func create_table_from_nested_array(columns: int, list: Array, spacing:int = 0):
	var table: String = "[table="+str(columns)+"]"
	var variable_data
	var buffer:=""
	for i in spacing:
		buffer += " "
	for a in list:
		for c in a:
			if c == null:
				variable_data = ""
			else:
				variable_data = str(c)
			print(variable_data)
			table = table + "[cell]"+variable_data+buffer+"[/cell]"
	table = table+"[/table]"
	#print(table)
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

"""
func out(color:int, source_name: String = "Unknown", data_1 = "", data_2 = "", data_3 = "", data_4 = "", data_5 = ""):
	var bracketed_source
	match slog_brackets:
		Brackets.ROUND:
			bracketed_source = "(" + source_name + ")"
		Brackets.SQUARE:
			bracketed_source = "[" + source_name + "]"
		Brackets.CURLY:
			bracketed_source = "{" + source_name + "}"

	var result = colorize_text_int(bracketed_source, color)
	var text_array:= [result, " ", data_1, data_2, data_3, data_4, data_5] 
	var final_print = "".join(text_array)
	print_rich(final_print)
	if sestem_ready == true:
		Ses.print_to_console(final_print)
"""



func colorize_text(text:String, color:Color):
	var color_hex: String = color.to_html(false)
	
	var color_start := "[color="+color_hex+"]"
	var color_end := "[/color]"

	var colorized_text = color_start + text + color_end
	return colorized_text




func colorize_text_int(text:String, color:int):
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


func generate_name_based_on_datetime(custom_name:String, space:=" "):
	var dt = get_datetime_string_formatted()
	var unique_name = custom_name + space + dt + ".txt"
	return unique_name



#	MUUTA TOI WAIT_SECONDS
#	JA SIT VOI KANS OLLA WAIT MINUTES
#	TAI HOURS
#	DAYS
#	UNTIL FURTHER NOTICE
func wait(seconds:float):
	await get_tree().create_timer(seconds).timeout




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



func save_as_text(file_name: String, contents, location: folder = folder.ROOT):
	var location_path = folders[location]
	var full_path = location_path.path_join(file_name)
	var split = full_path.split(".", false, 2)

	if split.size() == 2:
		full_path = split[0] + ".txt"
	else:
		full_path = full_path + ".txt"

	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file == null:
		out(self, Color.RED, "Error saving text file: Could not open path ", full_path, " for writing.")
		return false
	file.store_string(str(contents))
	file.close()
	return true



func save_as_json(file_name: String, contents, location: folder = folder.ROOT):
	var location_path = folders[location]
	var full_path = location_path.path_join(file_name)
	var split = full_path.split(".", false, 2)

	if split.size() == 2:
		full_path = split[0] + ".json"
	else:
		full_path = full_path + ".json"

	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file == null:
		out(self, Color.RED, "Error saving JSON file: Could not open path ", full_path, " for writing.")
		return false
	file.store_string(JSON.stringify(contents, "\t"))
	file.close()
	return true


func save_as_binary(file_name: String, contents, location: folder = folder.ROOT):
	var location_path = folders[location]
	var full_path = location_path.path_join(file_name)
	var split = full_path.split(".", false, 2)

	if split.size() == 2:
		full_path = split[0] + ".bin"
	else:
		full_path = full_path + ".bin"

	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file == null:
		out(self, Color.RED, "Error saving binary file: Could not open path ", full_path, " for writing.")
		return false
	file.store_buffer(var_to_bytes(contents))
	file.flush()
	file.close()
	return true


func load_file(file_name: String, location:folder = folder.ROOT):
	var location_path = folders[location]
	var full_path = location_path.path_join(file_name)
	var split = full_path.split(".", false, 2)
	var file
	var file_types: Array = ["txt", "json", "bin"]
	var file_type: String
	var result

	if split.size() == 1:
		for t in file_types.size():
			file = FileAccess.open(full_path+"."+file_types[t], FileAccess.READ)
			if file != null:
				file_type = file_types[t]
				break
	
	elif split.size() == 2:
		file = FileAccess.open(full_path, FileAccess.READ)
		file_type = split[1]

	else:
		out(self, Color.RED, "This shouldn't happen. What the fuck... (File loading error. More than two dots in file path.)")
		return null
	
	if file == null:
		out(self, Color.RED, "Could not load file at ", full_path, ": File was not found.")
		return null

	match file_type:
		"txt":
			result = file.get_as_text()
		"json":
			var data = file.get_as_text()
			result = JSON.parse_string(data)
			if data == null:
				out(self, Color.RED, "Error loading file: JSON parse failed.")
				return null
		"bin":
			var bytes = FileAccess.get_file_as_bytes(full_path+"."+file_type)
			result = bytes_to_var(bytes)
		_:
			out(self, Color.RED,"Error loading file: format '", file_type, "' is not supported.")
			return null
	file.close()
	return result



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


func get_datetime_str(seconds:bool = false, utc: bool = false):
	var dt = Time.get_datetime_dict_from_system(utc)
	var dt_str: String
	if seconds == false:
		dt_str = "%04d-%02d-%02d %02d-%02d" % [
			dt.year, dt.month, dt.day,	dt.hour, dt.minute
		]
	else:
		dt_str = "%04d-%02d-%02d %02d-%02d-%02d" % [
			dt.year, dt.month, dt.day,	dt.hour, dt.minute, dt.second
		]
	return dt_str



func load_json_from_folder(folder_path, file_name):
	var path = folder_path + file_name
	return load_json(path)


func create_text_file(file_path:String, data: String):
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		out(self, Color.RED, "Error at create_text_file():", file_path, "was null")
		return 1
	if data is String:
		file.store_string(data)
		return 0
	else:
		out(self, Color.RED, "Failed to create text file: parameter 'data' needs to be String")
		return 1


func save_text_file(file_name:String, text: String, path: String = root_path):
	var full_path = path.path_join(file_name)
	var split = full_path.split(".", false, 2)

	if split.size() == 2:
		full_path = split[0] + ".txt"
	else:
		full_path = full_path + ".txt"

	var file = FileAccess.open(full_path, FileAccess.WRITE)
	if file == null:
		out(self, Color.RED, "Error saving text file: Could not open path ", full_path, " for writing.")
		return false
	file.store_string(text)
	file.close()
	return true


func json_to_dict(json_string):
	var data = JSON.parse_string(json_string)
	
	if data == null:
		out(self, Color.RED, "JSON parse failed. Aborting.")
		return null
	if typeof(data) == TYPE_DICTIONARY:
		return data
	else:
		out(self, Color.RED, "Wrong variable type sorry lol")


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


func sort_resources_by_string_var(list: Array, property_name: String, order:= true):
	var sorted_list = list.duplicate()
	if order == true:
		sorted_list.sort_custom(func(a,b):
			return a.get(property_name).casecmp_to(b.get(property_name)) < 0)
		return sorted_list
	else:
		sorted_list.sort_custom(func(a,b):
			return a.get(property_name).casecmp_to(b.get(property_name)) > 0)
		return sorted_list
