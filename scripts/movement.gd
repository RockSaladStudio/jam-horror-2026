extends CharacterBody3D

@export var camera: Camera3D 
@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.005

@export_range(-90.0, 0.0, 0.1, "radians_as_degrees") var min_vertical_angle: float = -PI/2
@export_range(0.0, 90.0, 0.1, "radians_as_degrees") var max_vertical_angle: float = PI/4

var _is_defeated: bool = false

# Son mur / box
@onready var impact_sfx: AudioStreamPlayer = $ImpactSFX
@onready var aie_sfx: AudioStreamPlayer = $AieSFX
@export var aie_cooldown: float = 2.0  # secondes minimum entre deux "aïe"
@export var son_choc_box: AudioStream  # choc fort contre une box (sinon celui de ImpactSFX)
var _son_choc_mur: AudioStream
var _contre_mur := false
var _contre_box := false
var _aie_en_attente := false

# Son marche
@export var pas_distance: float = 1.6  # mètres entre deux pas
@export var sons_pas: Array[AudioStream] = []  # [son 1, son 2]
@onready var pas_sfx: AudioStreamPlayer = $StepSFX
var _distance_pas := 0.0
var _pied := 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_son_choc_mur = impact_sfx.stream

func set_defeated() -> void:
	_is_defeated = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	if _is_defeated:
		print("dead")
		velocity = Vector3.ZERO
		return

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

	# Pas : vitesse réelle, ~0 quand on pousse contre un mur
	var v := get_real_velocity()
	var vitesse := Vector2(v.x, v.z).length()
	if is_on_floor() and vitesse > 0.1:
		_distance_pas += vitesse * delta
		if _distance_pas >= pas_distance and sons_pas.size() >= 2:
			_distance_pas = 0.0
			pas_sfx.stream = sons_pas[_pied]
			pas_sfx.play()
			_pied = 1 - _pied  # 0, 1, 0, 1...
	else:
		_distance_pas = pas_distance  # à la reprise, le premier pas part tout de suite
		_pied = 0                     # et c'est toujours le son 1

	# Choc seulement au moment du contact, pas à chaque frame :
	# fort + "aïe" contre une box, faible contre un mur
	var touche := is_on_wall()
	var touche_box := _touche_box()
	if touche_box and not _contre_box:
		_choc(son_choc_box)
		_aie()
	elif touche and not _contre_mur:
		_choc(_son_choc_mur)
	_contre_mur = touche
	_contre_box = touche_box

func _choc(son: AudioStream) -> void:
	impact_sfx.stream = son if son else _son_choc_mur
	impact_sfx.play()

# Une box = une instance d'un GLB "box-*.glb" : le StaticBody3D généré à l'import
# a pour owner la racine de cette instance.
func _touche_box() -> bool:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_angle(0, up_direction) <= floor_max_angle:
			continue  # on marche dessus, ce n'est pas un choc
		var body := col.get_collider() as Node
		if body and body.owner and body.owner.scene_file_path.get_file().begins_with("box-"):
			return true
	return false

func _aie() -> void:
	if _aie_en_attente:
		return  # évite d'empiler plusieurs "aïe" si on se recogne pendant l'attente
	_aie_en_attente = true
	await get_tree().create_timer(1.0).timeout
	aie_sfx.play()
	await get_tree().create_timer(aie_cooldown).timeout
	_aie_en_attente = false

func _unhandled_input(event: InputEvent) -> void:
	if _is_defeated:
		return
	# Sur le web, le navigateur relâche la souris (Échap, plein écran) et ne la
	# rend que sur un clic du joueur : on la recapture au clic.
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.y = wrapf(rotation.y, 0.0, TAU)

		camera.rotation.x -= event.relative.y * mouse_sensitivity
		camera.rotation.x = clamp(camera.rotation.x, min_vertical_angle, max_vertical_angle)
