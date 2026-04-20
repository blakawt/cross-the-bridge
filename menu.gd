extends Control


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()




func _on_mute_music_pressed() -> void:
	pass # Replace with function body.
