extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()




var muted := false

func _on_mute_music_pressed() -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	
	muted = !muted
	AudioServer.set_bus_mute(bus_index, muted)
