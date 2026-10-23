extends Node3D

## Pas du monstre : de temps en temps, une petite marche lourde quelque part
## autour du joueur. Le monstre ne bouge pas, c'est juste pour l'ambiance.
## Muet tant que start() n'a pas été appelé (branché sur l'ouverture de la porte 1).

@export var player: Node3D
@export var sons_pas: Array[AudioStream] = []  # joués en alternance

@export_group("Rythme")
@export var delai_min: float = 8.0  # secondes entre deux marches
@export var delai_max: float = 20.0
@export var pas_min: int = 3  # nombre de pas par marche
@export var pas_max: int = 6
@export var intervalle_pas: float = 1.0  # secondes entre deux pas

@export_group("Position")
@export var distance_min: float = 4.0  # mètres autour du joueur
@export var distance_max: float = 9.0
@export var longueur_pas: float = 0.8  # la source avance un peu à chaque pas
@export var hauteur: float = 0.8  # au-dessus de l'origine du joueur : à peu près au sol

var actif := false

var _attente := 0.0
var _pas_restants := 0
var _pied := 0
var _direction_marche := Vector3.FORWARD

@onready var _audio: AudioStreamPlayer3D = $Audio

func start() -> void:
	if actif:
		return
	actif = true
	_attente = randf_range(delai_min, delai_max)

func _process(delta: float) -> void:
	if not actif or not player or sons_pas.is_empty():
		return
	_attente -= delta
	if _attente > 0.0:
		return
	if _pas_restants == 0:
		_commencer_marche()
	_jouer_pas()
	_pas_restants -= 1
	if _pas_restants > 0:
		_attente = intervalle_pas * randf_range(0.85, 1.15)
	else:
		_attente = randf_range(delai_min, delai_max)

# choisit un point au hasard autour du joueur et une direction de marche
func _commencer_marche() -> void:
	var angle := randf() * TAU
	var autour := Vector3(cos(angle), 0.0, sin(angle)) * randf_range(distance_min, distance_max)
	_audio.global_position = player.global_position + autour + Vector3.UP * hauteur
	_direction_marche = Vector3.FORWARD.rotated(Vector3.UP, randf() * TAU)
	_pas_restants = randi_range(pas_min, pas_max)
	_pied = 0

func _jouer_pas() -> void:
	if _pied > 0:
		_audio.global_position += _direction_marche * longueur_pas
	_audio.stream = sons_pas[_pied % sons_pas.size()]
	_audio.play()
	_pied += 1
