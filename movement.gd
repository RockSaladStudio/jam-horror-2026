extends CharacterBody3D

@export var camera: Camera3D
@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.005

@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_vertical_angle: float = -PI/2
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var max_vertical_angle: float = PI/4

# Son mur
@onready var impact_sfx: AudioStreamPlayer = $ImpactSFX
@onready var aie_sfx: AudioStreamPlayer = $AieSFX
var _contre_mur := false
var _aie := false
# Son marche
@export var pas_distance: float = 1.6  # mètres entre deux pas
@export var sons_pas: Array[AudioStream] = []  # [son 1, son 2]
@onready var pas_sfx: AudioStreamPlayer = $StepSFX
var _distance_pas := 0.0
var _pied := 0

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
	
	# Vitesse réelle : ~0 quand on pousse contre un mur
	var v := get_real_velocity()
	var vitesse := Vector2(v.x, v.z).length()
	if is_on_floor() and vitesse > 0.1:
		_distance_pas += vitesse * delta
		if _distance_pas >= pas_distance:
			_distance_pas = 0.0
			pas_sfx.stream = sons_pas[_pied]
			pas_sfx.play()
			_pied = 1 - _pied
	else:
		_distance_pas = pas_distance
		_pied = 0                     
	
	# Son seulement au moment du contact, pas à chaque frame passée contre le mur
	var touche := is_on_wall()
	if touche and not _contre_mur:
		_cogner_mur()
	_contre_mur = touche

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
			
func _cogner_mur() -> void:
	impact_sfx.play()
	if _aie:
		return  # Pour ne pas faire plusieurs "aïe"
	_aie = true
	await get_tree().create_timer(0.5).timeout
	aie_sfx.play()
	_aie = false
