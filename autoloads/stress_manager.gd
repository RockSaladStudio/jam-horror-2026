extends Node
## StressManager - Gère le niveau de stress du joueur
## Autoload déclaré via stress_manager.tscn, réglable par le designer dans l'Inspecteur

## Émis quand le palier de stress change (0 à 4)
signal tier_changed(tier: int)
## Émis quand le stress atteint le maximum (défaite)
signal stress_maxed

# Niveau de stress actuel
var stress: float = 0.0
# Référence au bandeau, assignée par le bandeau lui-même à son apparition dans la scène
var blindfold: Blindfold
# Palier actuel (0 à 4)
var current_tier: int = 0
# Temps passé avec le bandeau complètement baissé
var blindfold_down_time: float = 0.0
# Évite d'émettre stress_maxed à chaque frame une fois le maximum atteint
var has_maxed: bool = false

@export_group("Jauge")
## Stress maximum, l'atteindre déclenche la défaite
@export_range(1.0, 500.0, 1.0) var max_stress: float = 100.0
## Vitesse de montée du stress par seconde quand le monstre est vu
@export_range(0.0, 50.0, 0.1) var stress_increase_rate: float = 1.0
## Vitesse de descente du stress par seconde quand le bandeau reste baissé
@export_range(0.0, 50.0, 0.1) var stress_decrease_rate: float = 1.0
## Temps en secondes avec le bandeau baissé avant que le stress commence à descendre
@export_range(0.0, 10.0, 0.1) var stress_decrease_delay: float = 2.0

@export_group("Paliers")
## Seuil d'entrée de chaque palier (1, 2, 3, 4), dans l'ordre croissant et sous max_stress
@export var stress_thresholds: Array[float] = [20.0, 40.0, 60.0, 80.0]


func _process(delta: float) -> void:
	# Pas de bandeau (menu, scène pas encore prête) : rien à faire
	if not is_instance_valid(blindfold):
		return

	_update_decrease(delta)
	_update_tier()
	_check_max()


## Augmente le stress (appelé quand le monstre est vu)
func increase_stress(delta: float) -> void:
	stress = min(stress + stress_increase_rate * delta, max_stress)


## Fait redescendre le stress quand le bandeau reste baissé assez longtemps
func _update_decrease(delta: float) -> void:
	if blindfold.current_progress <= 0.0:
		blindfold_down_time += delta
		if blindfold_down_time >= stress_decrease_delay:
			stress = max(stress - stress_decrease_rate * delta, 0.0)
	else:
		blindfold_down_time = 0.0


## Renvoie le palier correspondant au stress actuel (0 à 4)
func get_tier() -> int:
	var tier := 0
	for threshold in stress_thresholds:
		if stress >= threshold:
			tier += 1
	return tier


## Émet tier_changed uniquement quand le palier change
func _update_tier() -> void:
	var new_tier := get_tier()
	if new_tier != current_tier:
		current_tier = new_tier
		tier_changed.emit(current_tier)
		print("Palier de stress : ", current_tier)


## Émet stress_maxed une seule fois quand le maximum est atteint
func _check_max() -> void:
	if stress >= max_stress and not has_maxed:
		has_maxed = true
		stress_maxed.emit()
		print("Stress max atteint")


## Réinitialise tout (à appeler au redémarrage d'une partie)
func reset_stress() -> void:
	stress = 0.0
	blindfold_down_time = 0.0
	has_maxed = false
	if current_tier != 0:
		current_tier = 0
		tier_changed.emit(0)
