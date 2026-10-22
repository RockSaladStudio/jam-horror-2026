extends MeshInstance3D

# Durée de vie du monstre (en secondes)
@export var lifespan: float = 5.0

# Le monstre peut-il disparaitre si le joueur baisse le bandeau ?
@export var disappear_on_blindfold_down: bool = true

# Référence au bandeau (assignée par le spawner)
var blindfold: Blindfold

# Timer pour la durée de vie
var lifetime_timer: float = 0.0


func _ready() -> void:
	lifetime_timer = 0.0


func _process(delta: float) -> void:
	# 1. Mettre à jour le timer de durée de vie
	lifetime_timer += delta
	if lifetime_timer >= lifespan:
		queue_free()
		return

	# 2. Disparaître si le joueur baisse le bandeau
	if disappear_on_blindfold_down and blindfold and blindfold.current_progress <= 0.0:
		queue_free()
		return

	# 3. Faire monter le stress si le joueur voit le monstre
	if _is_seen_by_player():
		StressManager.increase_stress(delta)


## Assigner la référence au bandeau (appelé par le spawner)
func set_blindfold(blindfold_ref: Blindfold) -> void:
	blindfold = blindfold_ref


## Vrai si le monstre est à l'écran, pas caché par un mur, et dans la partie découverte par le bandeau
func _is_seen_by_player() -> bool:
	if not blindfold:
		return false

	# Le spawner (parent du monstre) vérifie déjà le champ de vision et les murs
	var spawner = get_parent()
	if not spawner.is_point_visible(global_position):
		return false

	# Le bandeau découvre l'écran par le bas : le monstre doit être sous la limite du bandeau
	var screen_pos: Vector2 = spawner.camera.unproject_position(global_position)
	var screen_height: float = get_viewport().get_visible_rect().size.y
	return screen_pos.y / screen_height >= 1.0 - blindfold.current_progress
