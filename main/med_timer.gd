extends Control

var enabled: bool = false
var time: Dictionary


var source_id = "SignalTimer"


var timer: Timer

var bus_index = AudioServer.get_bus_index("Master")
var repeats_left: int = 0
var alarm_has_played: bool = false
var last_alarm_at_minute: int = -1


var test_tick_time_dicts: Array = [
	{"hour": 3, "minute": 59, "second": 57},
	{"hour": 3, "minute": 59, "second": 58},
	{"hour": 3, "minute": 59, "second": 59},
	{"hour": 4, "minute": 0, "second": 0},
	{"hour": 4, "minute": 0, "second": 1},
	{"hour": 4, "minute": 0, "second": 2},
	{"hour": 4, "minute": 0, "second": 3},
	{"hour": 4, "minute": 1, "second": 0},
	{"hour": 4, "minute": 1, "second": 1},
	{"hour": 4, "minute": 1, "second": 2},
	{"hour": 4, "minute": 1, "second": 3},
]

var spoofed_time_dict: Dictionary = {"hour": 3, "minute": 59, "second": 57}



var divider: int = 2
var tickrate: float = 1.0
var repeats: int = 1
var volume: float = 0.5
var offset: int = 0

var alarm_active: bool = true


func _ready() -> void:
	var result = load_config()
	if result == false:
		Ses.print_to_console("No config file was found. Creating one...")
		save_config()
		#Ses.print_to_console("")
	Ses.console_new_line.emit()

	Ses.add_command(self, "root", "start", "start", -1, "Starts time signal process")
	Ses.add_command(self, "root", "stop", "stop", -1, "Stops time signal process")
	Ses.add_command(self, "root", "test", "test", -1, "Tests the alarm")
	#Ses.add_command(self, "root", "test_full", "test_tick", -1, "Tests the whole system with fake time information")
	Ses.add_command(self, "root", "hours", "show_hours", -1, "Shows the hours with active alarms")


	Ses.add_command(self, "root", "volume", "command_set_volume", 1, "Sets alarm volume")
	Ses.add_command(self, "root", "tickrate", "set_tickrate", 1, "Adjusts effective tickrate by cooldown between ticks (float: seconds)")
	Ses.add_command(self, "root", "divider", "set_divider", 1, "Sets how many hours there are between alarms")
	Ses.add_command(self, "root", "offset", "seset_offsetti", 1, "Offsets the alarm hours (1 == one hour later, -1 == one hour earlier etc.)")
	Ses.add_command(self, "root", "repeats", "set_repeats", 1, "Sets how many times alarm gets repeated. -1 repeats based on the hour")


	Ses.add_command(self, "root", "config", "show_config", -1, "Shows current config")
	Ses.add_command(self, "root", "save_config", "save_config", -1, "Saves config")
	Ses.add_command(self, "root", "reload_config", "load_config", -1, "Reloads config")
	Ses.add_command(self, "root", "reset_config", "default_config", -1, "Resets config to defaults")


	var dumdum: PackedStringArray
	Ses.command_list_commands(dumdum)




func set_repeats(a: PackedStringArray):
	var new_a = Ses.match_type_strict(a[0], TYPE_INT)
	if new_a is int:
		repeats = new_a
		Ses.print_to_console("Repeats set to: ", str(repeats))


func show_config():
	Ses.print_to_console("Current config:")
	Ses.print_to_console("Volume: ", str(volume))
	Ses.print_to_console("Divider: ", str(divider))
	Ses.print_to_console("Offset: ", str(offset))
	Ses.print_to_console("Tickrate: ", str(tickrate))
	Ses.print_to_console("Repeats: ", str(repeats))


func set_divider(d: PackedStringArray):
	var new_d = Ses.match_type_strict(d[0], TYPE_INT)
	if new_d is int:
		divider = new_d
		Ses.print_to_console("Divider set to: ", str(divider))



func seset_offsetti(o: PackedStringArray):
	var new_o = Ses.match_type_strict(o[0], TYPE_INT)
	if new_o is int:
		offset = new_o
		print(new_o)
		Ses.print_to_console("Offset set to: ", str(offset))

	else:
		Ses.out(self, Color.RED, "AAAAAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHH")



func default_config():
	var config: Dictionary = { "tickrate" = 1, "repeats" = 1, "volume" = 0.5, "divider" = 1, "offset" = 0}
	Ses.save_as_binary("config", config)
	Ses.print_to_console("Config reset")


func save_config():
	var config: Dictionary = { "tickrate" = tickrate, "repeats" = repeats, "volume" = volume, "divider" = divider, "offset" = offset}
	Ses.save_as_binary("config", config)
	Ses.print_to_console("Config saved")


func load_config():
	var config = Ses.load_file("config")
	if config is not Dictionary:
		return false
	else:
		tickrate = config["tickrate"]
		repeats = config["repeats"]
		volume = config["volume"]
		divider = config["divider"]
		offset = config["offset"]
		Ses.print_to_console("Config loaded")
		return true


func show_hours():
	time = Time.get_time_dict_from_system(false)
	var divisions: Array[int]
	for i in 24:
		if i % divider == 0:
			divisions.append(i)
	for b in divisions.size():
		divisions[b] = posmod(divisions[b] + offset, 24)

	Ses.print_to_console("Active hours: ", str(divisions))



func check_hour(hour: int):
	time = Time.get_time_dict_from_system(false)
	var divisions: Array[int]
	for i in 24:
		if i % divider == 0:
			divisions.append(i)
	for b in divisions.size():
		divisions[b] = posmod(divisions[b] + offset, 24)


	if divisions.has(hour) == true:
		return true
			
	else:
		return false

func check_hour_test(hour: int):
	var divisions: Array[int]
	for i in 24:
		if i % divider == 0:
			divisions.append(i)
	for b in divisions.size():
		divisions[b] = posmod(divisions[b] + offset, 24)


	if divisions.has(hour) == true:
		return true
			
	else:
		return false


func tick():
	while true:
		if enabled == false:
			break
		else:
			await Ses.wait(tickrate)
			if enabled == false:
				break
			time = Time.get_time_dict_from_system(false)
			if time["minute"] == 0:
				if check_hour(time["hour"]) == true and alarm_has_played == false:
					activate_alarm(time["minute"])
					alarm_has_played = true
				elif check_hour(time["hour"] == false):
					alarm_has_played = false

		alarm_tick()
		var next_ding_at = get_next_ding_time(time["hour"])
		var next_ding_print
		if next_ding_at != -1:
			next_ding_print = str(next_ding_at)
		else:
			next_ding_print = "Unknown"
		Ses.out(self, Color.WHITE, "Current time: ", "%02d:%02d:%02d" % [time["hour"], time["minute"], time["second"]], "   Next alarm at: ", next_ding_print, ":00")


func get_spoofed_time_dict(adder: int):
#	var total_seconds = (spoofed_time_dict["hour"] * 3600) + (spoofed_time_dict["minute"] * 60) + spoofed_time_dict["second"]

	var total_seconds = spoofed_time_dict["hour"] * 3600 + spoofed_time_dict["minute"] * 60 + spoofed_time_dict["second"]


	total_seconds += adder
	var j = total_seconds % 3600
	var h = total_seconds / 3600
	var m = j / 60
	var s = j % 60
	
	var new_dict: Dictionary = {"hour": h, "minute": m, "second": s}
	return new_dict



func test_tick():
	var t
	var counter: int = 0
	enabled = true
	while true:
		if enabled == false:
			break
		else:
			await Ses.wait(1.0)
			if enabled == false:
				break
			t = get_spoofed_time_dict(counter)
			if t["minute"] == 0:
				if check_hour_test(t["hour"]) == true and alarm_has_played == false:
					activate_alarm(t["minute"])
					alarm_has_played = true
				elif check_hour_test(t["hour"]) == false:
					alarm_has_played = false

		alarm_tick()
		var next_ding_at = get_next_ding_time(t["hour"])
		var next_ding_print
		if next_ding_at != -1:
			next_ding_print = str(next_ding_at)
		else:
			next_ding_print = "Unknown"
		Ses.out(self, Color.WHITE, "Current time: ", "%02d:%02d:%02d" % [t["hour"], t["minute"], t["second"]], "   Next alarm at: ", next_ding_print, ":00")
		counter += 1

func activate_alarm(current_minute: int = 0, test_mode: bool = false):
	if enabled == false:
		Ses.out(self, Color.RED, "Timer must be running for testing the alarm. Enable it by entering 'start'")
		return
	if test_mode == true:
		last_alarm_at_minute = -1

	if last_alarm_at_minute == current_minute:
		return
	
	if repeats >= 0:
		repeats_left = repeats		
	else:
		var hours = time["hour"]
		if hours == 0:
			repeats_left = 12
		elif hours > 12:
			repeats_left = hours-12

		repeats_left = time["hour"]
	Ses.print_to_console("Repeating the alarm ", str(repeats_left), " times")
	last_alarm_at_minute = current_minute



func alarm_tick():
	if repeats_left > 0:
		ding()
		repeats_left -= 1
		Ses.print_to_console("Repeats left: ", str(repeats_left))


func test():
	activate_alarm(0, true)

func get_next_ding_time(current_hour):
	if divider > 24 or divider <= 0:
		return
	var next_hour_number
	for i in 24:
		next_hour_number = posmod(current_hour + i, 24)
		if next_hour_number % divider == 0 and next_hour_number != current_hour:
			return next_hour_number

	return -1


	

func ding():
	set_volume()
	AudioManager.play_se(SoundEffect.id.REVOLVER_DEFAULT)
	Ses.out(self, Color.WHITE, "AEUGH!")


func start():
	enabled = true
	Ses.print_to_console("Timer started")

	tick()


func set_tickrate(argument: PackedStringArray):
	tickrate = Ses.match_type_strict(argument[0], TYPE_FLOAT)
	Ses.print_to_console("Tickrate set to: ", str(tickrate))



func command_set_volume(arguments: PackedStringArray):
	var float_conversion = Ses.match_type_strict(arguments[0], TYPE_FLOAT)
	if float_conversion is float:
		volume = float_conversion
		set_volume()
		Ses.print_to_console("Volume set to: ", str(volume))



func set_volume():
	var db_val = linear_to_db(volume)
	AudioServer.set_bus_volume_db(bus_index, db_val)



func stop():
	if enabled == true:
		enabled = false
		repeats_left = 0
		Ses.print_to_console("Timer stopped")
		alarm_has_played = false
		last_alarm_at_minute = -1
