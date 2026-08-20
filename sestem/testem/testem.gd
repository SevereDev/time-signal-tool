extends SesLibrary

var source_id = "Testem"

var test_string:= "Tämä on testemin testitekstiä."
var test_int:= 69
var test_string_array:= ["Test", "them", "with", "Testem"] 
var test_array:= ["Test", "them", "with", "Testem", 123]
var test_string_dict:= {"first": "Test", "second": "them", "third": "with", "fourth": "Testem"}
var test_dict:= {"first": "Test", "second": "them", "third": "with", "fourth": "Testem", "fifth": 123}


var test_variables:Array = [test_string, test_int, test_array, test_string_array, test_dict, test_string_dict]

#	report structure:
#	testname, result(success/fail), description

func _ready() -> void:
	Ses.add_command(self, "testem", "save", "test_save_load_functionality", -1, "Runs a test for SES-library's save system.")

func _exit_tree() -> void:
	Ses.remove_directory("test")


func test_save_load_functionality():
	var results: Array[TestReport]
	for v in test_variables:
		results.append(text_saving(v))

	for v in test_variables:
		results.append(json_saving(v))
	
	for v in test_variables:
		results.append(binary_saving(v))
	#var var_names: PackedStringArray = ["test_name", "result","parameter_type","description"]
	Ses.print_to_console("Test report: save/load functionality:")
	var report_exports: Array[Array]
	for r in results:
		report_exports.append(r.get_data())	
		print(r.get_data())
	var table = Ses.create_table_from_nested_array(4, report_exports, 8)
	Ses.print_to_console(table)


func text_saving(test_data):
	var report = TestReport.new()
	report.test_name = ".txt files"
	report.parameters = test_data
	var result = save_as_text("txt_save_test", test_data, folder.TESTS)
	if result == false:
		report.result = false
		report.description = "Could not save file."
		return report
	else:
		var loaded_data = load_file("txt_save_test", folder.TESTS)
		if loaded_data == null:
			report.result = false
			report.description = "Could not load file."
			return report
		else:
			if typeof(test_data) != typeof(loaded_data):
				report.result = false
				report.description = "Loaded file data was not the same type as original."
				return report
			else:
				if test_data != loaded_data:
					report.result = false
					report.description = "Loaded data was the same type, but not the same value as the original."
					return report
				else:
					report.result = true
					report.description = "Data was saved and loaded successfully"
					return report


func json_saving(test_data):
	var report = TestReport.new()
	report.test_name = ".json files"
	report.parameters = test_data
	var result = save_as_json("json_save_test", test_data, folder.TESTS)
	if result == false:
		report.result = false
		report.description = "Could not save file."
		return report
	else:
		var loaded_data = load_file("json_save_test", folder.TESTS)
		if loaded_data == null:
			report.result = false
			report.description = "Could not load file."
			return report
		else:

			if typeof(test_data) != typeof(loaded_data):
				report.result = false
				report.description = "Loaded file data was not the same type as original."
				return report
			else:
				if test_data != loaded_data:
					report.result = false
					report.description = "Loaded data was the same type, but not the same value as the original."
					return report
				else:
					report.result = true
					report.description = "Data was saved and loaded successfully"
					return report


func binary_saving(test_data):
	var report = TestReport.new()
	report.parameters = test_data
	report.test_name = ".bin files"
	var result = save_as_binary("binary_save_test", test_data, folder.TESTS)
	if result == false:
		report.result = false
		report.description = "Could not save file."
		return report
	else:
		var loaded_data = load_file("binary_save_test", folder.TESTS)
		if loaded_data == null:
			report.result = false
			report.description = "Could not load file."
			return report
		else:
			if typeof(test_data) != typeof(loaded_data):
				report.result = false
				report.description = "Loaded file data was not the same type as original."
				return report
			else:
				if test_data != loaded_data:
					report.result = false
					report.description = "Loaded data was the same type, but not the same value as the original."
					return report
				else:
					report.result = true
					report.description = "Data was saved and loaded successfully"
					return report

