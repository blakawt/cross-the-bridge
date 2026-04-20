extends CharacterBody3D

# Constantes de vitesse
const WALK_SPEED = 8.0
const SPRINT_SPEED = 14.0
const JUMP_FORCE = 10.0
const DASH_SPEED = 25.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 0.5
const GRAVITY = 30.0
const ACCELERATION = 40.0
const FRICTION = 30.0
const AIR_ACCELERATION = 15.0
const AIR_FRICTION = 10.0
const MOUSE_SENS = 0.003

# References
@onready var camera = $Camera3D

# Variables de mouvement
var current_velocity = Vector3.ZERO
var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

# Variables camera
var camera_yaw = 0.0
var camera_pitch = 0.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Souris libérer/capturer
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Mouvements souris - tous les axes
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			camera_yaw -= event.relative.x * MOUSE_SENS
			camera_pitch -= event.relative.y * MOUSE_SENS
			camera_pitch = clamp(camera_pitch, -PI/2.2, PI/2.2)
			
			# Appliquer rotation au joueur (yaw) et à la caméra (pitch)
			rotation.y = camera_yaw
			camera.rotation.x = camera_pitch
			camera.rotation.y = 0  # Reset pour éviter doublon
			camera.rotation.z = 0
	
	# Echap pour libérer
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	handle_dash(delta)
	handle_gravity(delta)
	handle_movement(delta)
	handle_jump()
	
	move_and_slide()

func handle_movement(delta):
	if is_dashing:
		return
	
	# Récupérer input clavier AZERTY
	var input_dir = Vector3.ZERO
	
	if Input.is_key_pressed(KEY_Z):  # Z en avant
		input_dir.z -= 1
	if Input.is_key_pressed(KEY_S):  # S en arrière
		input_dir.z += 1
	if Input.is_key_pressed(KEY_Q):  # Q à gauche
		input_dir.x -= 1
	if Input.is_key_pressed(KEY_D):  # D à droite
		input_dir.x += 1
	
	# Normaliser direction
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
	
	# Appliquer rotation du joueur pour déplacement relatif à la caméra
	var move_direction = (transform.basis * input_dir)
	move_direction.y = 0
	move_direction = move_direction.normalized()
	
	# Déterminer vitesse cible
	var target_speed = WALK_SPEED
	if Input.is_key_pressed(KEY_SHIFT):
		target_speed = SPRINT_SPEED
	
	# Accélération/friction au sol ou en l'air
	var accel = ACCELERATION if is_on_floor() else AIR_ACCELERATION
	var fric = FRICTION if is_on_floor() else AIR_FRICTION
	
	# Appliquer accélération/friction
	if move_direction.length() > 0:
		current_velocity = current_velocity.lerp(move_direction * target_speed, accel * delta)
	else:
		current_velocity = current_velocity.lerp(Vector3.ZERO, fric * delta)
	
	velocity.x = current_velocity.x
	velocity.z = current_velocity.z

func handle_gravity(delta):
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		if velocity.y < 0:
			velocity.y = 0

func handle_jump():
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = JUMP_FORCE

func handle_dash(delta):
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			velocity = Vector3.ZERO
	
	dash_cooldown_timer -= delta
	
	if Input.is_key_pressed(KEY_E) and not is_dashing and dash_cooldown_timer <= 0:
		# Récupérer direction actuelle AZERTY
		var input_dir = Vector3.ZERO
		if Input.is_key_pressed(KEY_Z):
			input_dir.z -= 1
		if Input.is_key_pressed(KEY_S):
			input_dir.z += 1
		if Input.is_key_pressed(KEY_Q):
			input_dir.x -= 1
		if Input.is_key_pressed(KEY_D):
			input_dir.x += 1
		
		if input_dir.length() > 0:
			input_dir = input_dir.normalized()
			var dash_dir = transform.basis * input_dir
			dash_dir.y = 0
			velocity = dash_dir.normalized() * DASH_SPEED
		else:
			# Dash avant si aucune direction
			velocity = -transform.basis.z * DASH_SPEED
		
		is_dashing = true
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
