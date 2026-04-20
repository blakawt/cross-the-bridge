extends Area3D

@export var restart_delay := 0.1

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player":
		restart_level()


func restart_level():
	await get_tree().create_timer(restart_delay).timeout
	get_tree().reload_current_scene()
