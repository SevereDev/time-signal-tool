extends CanvasLayer

var source_id:= "Console"

@onready var text_field = $%TextField
@onready var line_edit = $%LineEdit
#@onready var suggestion_panel = $%SuggestionPanel
#@onready var suggestion_list = $%SuggestionList

@export var user_input_color: Color = Color.WHITE
@export var scroll_bar_color: Color = Color.BLACK
@export var scroll_bar_corners: int = 0
@export var suggestions: bool = false

var input_history: Array = [""]
var ihp: int = 0
var input_cache: String = ""
var first_cycling: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Ses.console_print.connect(_on_console_print)
	Ses.console_new_line.connect(_on_new_line_signal)
	Ses._console_connected()
#	suggestion_panel.visible = false
#	suggestion_list.focus_mode = Control.FOCUS_NONE
	line_edit.gui_input.connect(_on_line_edit_gui_input)
	adjust_scrollbar_color()
	line_edit.edit()
"""
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_console"):
		toggle_visibility()
"""

func adjust_scrollbar_color():#	Vittu tää paska moottori oikeesti
	var the_bar = text_field.get_v_scroll_bar()
	var the_new_look = StyleBoxFlat.new()
	the_new_look.bg_color = scroll_bar_color
	the_new_look.set_corner_radius_all(scroll_bar_corners)
	var the_rails = StyleBoxFlat.new()
	the_rails.bg_color = scroll_bar_color
	the_bar.add_theme_stylebox_override("grabber", the_new_look)
	the_bar.add_theme_stylebox_override("scroll", the_rails)

"""
func _input(event: InputEvent)-> void:
	if event is InputEventKey and event.pressed:
		if InputMap.event_is_action(event, "open_console"):
			get_viewport().set_input_as_handled()
"""

func _on_line_edit_gui_input(event):
	if not event is InputEventKey:
		return
	if event.is_action_pressed("ui_up"):
		line_edit.accept_event()
		history_cycle(1)
	if event.is_action_pressed("ui_down"):
		line_edit.accept_event()
		history_cycle(-1)



func history_cycle(maneuver: int):
	#var original_ihp = ihp
	ihp = ihp + maneuver
	var history_index = posmod(ihp, input_history.size())
	print(history_index)
	if first_cycling == true:
		if line_edit.text == null:
			input_history[0] = ""
		else:
			input_history[0] = line_edit.text
		first_cycling = false
	line_edit.text = input_history[history_index]
	move_caret_to_end()

func history_reset_search():
	ihp = 0
	input_history[0] = ""
	first_cycling = true


func history_clear():
	input_history = [""]
	ihp = 0


func _on_console_print(a = "text missing from print signal", b:="",c:="",d:="",e:="",f:="",g:="",h:="",i:="",j:="",k:="",l:="",m:="",n:=""):
	print_text(a,b,c,d,e,f,g,h,i,j,k,l,m,n)



func print_text(a="", b:="",c:="",d:="",e:="",f:="",g:="",h:="",i:="",j:="",k:="",l:="",m:="",n:=""):
	if a == "":
		return
	new_line()
	text_field.append_text(a+b+c+d+e+f+g+h+i+j+k+l+m+n)


func _on_new_line_signal():
	new_line()


func new_line():
	text_field.newline()


func toggle_visibility():
	if self.visible == true:
		self.hide()
		line_edit.unedit()
	else:
	#	Ses.update_command_suggestion_array()
		self.show()
		line_edit.edit()


func move_caret_to_end():
	line_edit.caret_column = line_edit.text.length()


func _on_line_edit_text_changed(text):
	var history_index = posmod(ihp, input_history.size())
	if history_index == 0:
		input_history[0] = text


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text == "":
		return
	line_edit.clear()
	new_line()
	print_text(Ses.colorize_text(new_text, user_input_color))
	input_history.insert(1, new_text)
	history_reset_search()
	Ses.execute_command(new_text)
