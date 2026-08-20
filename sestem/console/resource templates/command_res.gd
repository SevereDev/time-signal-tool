extends Resource
class_name Command

var command_name: String
var command_callable: Callable
var minimum_arguments: int
var description: String = "No description available."


signal command_ran


func _run(argument_strings: PackedStringArray):
	var given_argument_count: int = argument_strings.size()
	
	if minimum_arguments > given_argument_count:
		print("Running error at command: '", command_name,"'", "only received ", minimum_arguments, " arguments. Expected ", minimum_arguments)
		return "error out the ass"
	match argument_strings.size():#	Tää oli fiksuin tapa tehä tää ihan oikeesti >:(
		0:
			command_callable.call()
		1:
			command_callable.call(argument_strings[0])
		2:
			command_callable.call(argument_strings[0], argument_strings[1])
		3:
			command_callable.call(argument_strings[0], argument_strings[1], argument_strings[2])
		4:
			command_callable.call(argument_strings[0], argument_strings[1], argument_strings[2], argument_strings[3])
		5:
			command_callable.call(argument_strings[0], argument_strings[1], argument_strings[2],  argument_strings[3], argument_strings[4])
		_:
			return "Freak the fuck out and crash the entire engine. This guys wanted more than five arguments."

	command_ran.emit(argument_strings)


func run(argument_strings: PackedStringArray):
	var given_argument_count: int = argument_strings.size()
	
	if minimum_arguments > given_argument_count:
		print("Running error at command: '", command_name,"'", "only received ", minimum_arguments, " arguments. Expected ", minimum_arguments)
		return "error out the ass"


	if minimum_arguments >= 0:
		command_callable.call(argument_strings)
		command_ran.emit(argument_strings)
	else:
		var empty_arguments: PackedStringArray = []
		command_callable.call()
		command_ran.emit(empty_arguments)
