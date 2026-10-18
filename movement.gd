extends CharacterBody3D

@export var camera: Camera3D
@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.005

@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_vertical_angle: float = -PI/2
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var max_vertical_angle: float = PI/4

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# la camera n'est pas toujours assignee dans l'inspecteur : on la retrouve
	if not camera:
		camera = get_node_or_null(^"Camera3D") as Camera3D

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# lacet sur le corps
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.y = wrapf(rotation.y, 0.0, TAU)

		# tangage sur la camera uniquement : incliner le corps ferait partir
		# le vecteur de deplacement dans le sol ou le plafond
		if camera:
			camera.rotation.x -= event.relative.y * mouse_sensitivity
			camera.rotation.x = clamp(camera.rotation.x, min_vertical_angle, max_vertical_angle)
