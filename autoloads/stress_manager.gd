extends Node
## StressManager - Gère le niveau de stress du joueur et les paramètres de spawn
## À déclarer comme Autoload dans Project Settings > AutoLoad avec le nom "StressManager"

# Niveau de stress actuel (0-100)
var stress: float = 0.0

# Taux d'augmentation du stress par seconde quand un monstre est visible
@export var stress_increase_rate: float = 1.0

# Stress maximum
@export var max_stress: float = 100.0

# Référence à la caméra du joueur (à set depuis le MonsterSpawner)
@export var camera: Camera3D

# Seuils de stress pour les différents niveaux de spawn
# [0-25], [25-50], [50-75], [75-100]
@export var stress_thresholds: Array[float] = [0.0, 25.0, 50.0, 75.0]

# Intervalles de spawn (en secondes) pour chaque palier de stress
# Plus le stress est élevé, plus le monstre apparaît fréquemment
@export var spawn_intervals: Array[float] = [5.0, 3.0, 1.0, 0.5]

# Multiplicateurs de taille minimale et maximale
@export var min_size_multiplier: float = 1.0
@export var max_size_multiplier: float = 3.0

# Multiplicateurs de distance minimale et maximale (0 = très proche, 1 = distance normale)
@export var min_distance_multiplier: float = 0.3
@export var max_distance_multiplier: float = 1.0


## Augmente le stress (appelé automatiquement quand un monstre est dans le FOV)
func increase_stress(delta: float) -> void:
	stress = min(stress + stress_increase_rate * delta, max_stress)


## Réinitialise le stress (optionnel, si besoin pour le gameplay)
func reset_stress() -> void:
	stress = 0.0


## Obtient l'intervalle de spawn actuel en secondes (basé sur le stress)
func get_spawn_interval() -> float:
	if stress >= stress_thresholds[3]:
		return spawn_intervals[3]
	elif stress >= stress_thresholds[2]:
		return spawn_intervals[2]
	elif stress >= stress_thresholds[1]:
		return spawn_intervals[1]
	else:
		return spawn_intervals[0]


## Obtient la probabilité de spawn par seconde (alternative à l'intervalle)
## Utile si tu préfères un système probabiliste
func get_spawn_probability() -> float:
	# [0-25]: 10%, [25-50]: 30%, [50-75]: 70%, [75+]: 100%
	var probabilities: Array[float] = [0.1, 0.3, 0.7, 1.0]
	if stress >= stress_thresholds[3]:
		return probabilities[3]
	elif stress >= stress_thresholds[2]:
		return probabilities[2]
	elif stress >= stress_thresholds[1]:
		return probabilities[1]
	else:
		return probabilities[0]


## Calcule le multiplicateur de taille basé sur le stress actuel
## plus le stress est élevé, plus le monstre est gros
func get_size_multiplier() -> float:
	var ratio = stress / max(max_stress, 0.001)
	return lerp(min_size_multiplier, max_size_multiplier, ratio)


## Calcule le multiplicateur de distance basé sur le stress actuel
## plus le stress est élevé, plus le monstre apparaît proche
func get_distance_multiplier() -> float:
	var ratio = stress / max(max_stress, 0.001)
	return lerp(max_distance_multiplier, min_distance_multiplier, ratio)


## Calcule la taille du monstre basée sur le stress
func get_monster_scale() -> Vector3:
	var multiplier = get_size_multiplier()
	return Vector3(multiplier, multiplier, multiplier)
