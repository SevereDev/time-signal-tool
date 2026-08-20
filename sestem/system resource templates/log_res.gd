extends Resource
class_name LogEntry

enum ClassificationType{
	MESSAGE,
	WARNING,
	ERROR
}

var classification: ClassificationType
var id: String
var info: String

var timestamp: String

var additional_data: Array

# Called when the node enters the scene tree for the first time.
func _init() -> void:
	timestamp = Ses.get_datetime_string_formatted()


func convert_to_string():
	var class_str = str(classification)
	var additional_data_str = str(additional_data)

	var formatted_text  = "Log entry: "+ id +" Classification: "+ class_str +" Timestamp: " + timestamp + " Additional data: " + additional_data_str
	return formatted_text