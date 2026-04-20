extends CharacterBody3D

@export var speed := 5.0
@export var gravity := 9.8

func _ready():
	# Vérifie que le joueur ne spawn pas sous le sol
	if not is_on_floor():
		velocity.y = 0

func _physics_process(delta):
	# Appliquer la gravité
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Mouvement simple (optionnel)
	var direction = Vector3.ZERO

	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1

	direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()
