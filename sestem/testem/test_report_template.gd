extends Resource
class_name TestReport

var test_name: String
var result: bool
var description: String = "No description given."
var parameters

var parameter_type: String:
	get: return type_string(typeof(parameters))


func get_data(rich_formatting: bool = true):
	var data: Array = []
	data.resize(4)
	data[0] = test_name+":"

	if rich_formatting == true:
		if result == true:
			data[1] = "[color=GREEN]PASSED[/color]"
		else:
			data[1] = "[color=RED]FAILED[/color]"
	else:
		if result == true:
			data[1] = "PASSED"
		else:
			data[1] = "FAILED"
	
	data[2] = str(parameter_type)

	data[3] = description
	return data


func get_data_as_string(rich_formatting: bool = true):
	var data: Array = []
	data.resize(4)
	data[0] = test_name+":"

	if rich_formatting == true:
		if result == true:
			data[1] = "[color=GREEN]PASSED[/color]"
		else:
			data[1] = "[color=RED]FAILED[/color]"
	else:
		if result == true:
			data[1] = "PASSED"
		else:
			data[1] = "FAILED"
	
	data[2] = str(parameter_type)

	data[3] = description
	var data_str: String = data[0]+" "+data[1]+" "+data[2]+" "+data[3]
	return data_str