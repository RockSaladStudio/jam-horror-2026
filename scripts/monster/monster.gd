extends MeshInstance3D

# Durée de vie du monstre (en secondes)
@export var lifespan: float = 5.0

# Le monstre peut-il disparaitre si le joueur baisse le bandeau ?
@export var disappear_on_blindfold_down: bool = true

# Référence au bandeau (sera assignée par le spawner)
var blindfold: Blindfold

# Position initiale (pour le wander)
var start_position: Vector3

# Direction aléatoire pour le wander
var wander_direction: Vector3

# Temps de changement de direction pour le wander
var wander_change_time: float = 0.0
var wander_change_interval: float = 2.0

# Timer pour la durée de vie
var lifetime_timer: float = 0.0


func _ready() -> void:
	# Sauvegarder la position initiale
	start_position = global_position
	
	# Démarrer le timer de durée de vie
	lifetime_timer = 0.0


func _process(delta: float) -> void:
	# 1. Mettre à jour le timer de durée de vie
	lifetime_timer += delta
	if lifetime_timer >= lifespan:
		queue_free()
		return
	
	# 2. Vérifier si le monstre doit disparaître (bandeau baissé)
	if disappear_on_blindfold_down and blindfold and blindfold.current_progress <= 0.0:
		queue_free()
		return


## Assigner la référence au bandeau (appelé par le spawner)
func set_blindfold(blindfold_ref: Blindfold) -> void:
	blindfold = blindfold_ref


## Configurer les propriétés basées sur le stress (appelé par le spawner)
# func setup_from_stress(stress: float, stress_manager: StressManager) -> void:
# 	# La taille est déjà set par le spawner via scale
# 	# On peut ajouter d'autres effets ici
# 	pass
