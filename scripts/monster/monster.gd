extends Node3D

# Le monstre peut-il disparaitre si le joueur baisse le bandeau ?
@export var disappear_on_blindfold_down: bool = true

# Référence au bandeau (assignée par le spawner)
var blindfold: Blindfold

# Timer pour la durée de vie
var player_death_timer: float = 0.0

@export var player_death_time: float = 5.0

# Reference à la camera
var camera: Camera3D

# Référence au joueur
var player: CharacterBody3D

# Son à jouer à la mort du joueur
@export var screamer_sound: AudioStream

# Lecteur audio pour le screamer
var screamer_player: AudioStreamPlayer


func _ready() -> void:
	player_death_timer = 0.0
	
	# Créer le lecteur audio pour le screamer
	screamer_player = AudioStreamPlayer.new()
	add_child(screamer_player)
	if screamer_sound:
		screamer_player.stream = screamer_sound


func _process(delta: float) -> void:
	player_death_timer += delta

	# Déclencher la mort du joueur quand le timer est écoulé
	if player_death_timer >= player_death_time:
		trigger_player_death()
		return

	# Disparaître si le joueur baisse le bandeau
	if disappear_on_blindfold_down and blindfold and blindfold.current_progress <= 0.0:
		queue_free()
		return

	# Faire monter le stress si le joueur voit le monstre
	if _is_seen_by_player():
		StressManager.increase_stress(delta)
	else:
		queue_free()

	var x = global_rotation.x
	var z = global_rotation.z
	look_at(camera.global_position)
	global_rotation.x = x
	global_rotation.z = z


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


## Déclenche la mort du joueur quand le timer est écoulé
func trigger_player_death() -> void:
	# Désactiver les mouvements du joueur
	if player:
		player.set_defeated()

	# Positionner le monstre devant la caméra
	if camera:
		# Position à une distance fixée devant la caméra
		var offset = -camera.global_transform.basis.z * 0.5
		global_position = camera.global_position + offset

		var x = global_rotation.x
		var z = global_rotation.z
		# Regarder vers la caméra
		look_at(camera.global_position, Vector3.UP)
		global_rotation.x = x
		global_rotation.z = z
		position.y = 0

	# Jouer le son
	if screamer_player and screamer_sound:
		screamer_player.play()

	get_tree().create_timer(2).timeout.connect(_death_timeout)
	# Gelé le timer
	player_death_timer = player_death_time

func _death_timeout() -> void:
	get_tree().quit()
