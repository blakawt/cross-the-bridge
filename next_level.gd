extends Area3D

@export var restart_delay := 0.1

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		get_tree().change_scene_to_file("res://Levels/Desert.tscn")
