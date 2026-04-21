extends Control

var menu_open := false
var muted := false

func _ready():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_menu()

func toggle_menu():
	menu_open = !menu_open
	
	visible = menu_open
	
	if menu_open:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)   # souris libre
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # souris verrouillée

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_mute_music_pressed() -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	muted = !muted
	AudioServer.set_bus_mute(bus_index, muted)
