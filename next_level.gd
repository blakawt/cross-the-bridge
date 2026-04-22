extends Area3D

@export var restart_delay := 0.1
var simultaneous_scene = preload("res://Levels/Desert.tscn").instantiate()
func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		get_tree().root.add_child(simultaneous_scene)
