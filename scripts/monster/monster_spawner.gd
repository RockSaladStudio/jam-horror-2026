extends Node3D

# Scène du monstre à instancier
@export var monster_scene: PackedScene

# Référence à la caméra du joueur
@export var camera: Camera3D

# Référence au bandeau du joueur
@export var blindfold: Blindfold

# Angle de champ de vision supplémentaire (en degrés)
# 0 = utiliser uniquement le frustum de la caméra
# >0 = restreindre davantage le FOV
@export var fov_angle: float = 0.0

# Duré de vie du monstre (en secondes) - après ce délai, il disparaît et un nouveau peut spawner
@export var monster_lifespan: float = 5.0

# Distance maximale de spawn (0 = pas de limite)
@export var max_spawn_distance: float = 0.0

# Distance minimale de spawn (pour éviter que le monstre apparaisse trop proche/loin)
@export var min_spawn_distance: float = 1.0

# Espace 3D pour les raycasts
var space_state: PhysicsDirectSpaceState3D

# Masque de collision pour le raycast (layer à vérifier)
@export var collision_mask: int = 1

# Liste des points de spawn valides (Marker3D ou Node3D)
var spawn_points: Array[Node3D] = []

# Référence au monstre ACTUEL (un seul à la fois)
var current_monster: Node3D = null

# Temps du dernier spawn
var last_spawn_time: float = 0.0

# Cooldown minimum entre les spawns (pour éviter le spam)
@export var min_spawn_cooldown: float = 0.1


func _ready() -> void:
	# Récupérer l'espace 3D pour les raycasts
	space_state = get_world_3d().direct_space_state
	
	# # Initialiser StressManager avec la caméra
	# if StressManager:
	# 	StressManager.camera = camera
	
	# Récupérer tous les enfants comme points de spawn
	for child in get_children():
		if child is Node3D:
			spawn_points.append(child)
	
	print("MonsterSpawner initialisé avec ", spawn_points.size(), " points de spawn")


func _process(delta: float) -> void:
	# 1. Nettoyer le monstre mort
	cleanup_dead_monster()
	
	# 2. Mettre à jour le stress si le monstre est visible
	# if camera:  # Vérifier que la caméra est assignée
	# 	update_stress_from_monster(delta)
	
	# 3. Vérifier les conditions de spawn
	if can_spawn_monster():
		spawn_monster()


## Met à jour le stress basé sur le monstre actuel visible
# func update_stress_from_monster(delta: float) -> void:
# 	if not StressManager:
# 		return
	
# 	# Vérifier si le monstre actuel est visible
# 	if current_monster and is_instance_valid(current_monster):
# 		if camera.is_position_in_frustum(current_monster.global_position):
# 			StressManager.increase_stress(delta)


## Nettoie le monstre mort
func cleanup_dead_monster() -> void:
	if current_monster and not is_instance_valid(current_monster):
		current_monster = null


## Vérifie si on peut spawner un monstre
func can_spawn_monster() -> bool:
	# 1. Vérifier que le bandeau est en train d'être levé
	if blindfold.current_progress <= 0.0:
		return false
	
	# 2. Vérifier qu'AUCUN monstre n'est déjà actif
	if current_monster and is_instance_valid(current_monster):
		return false
	
	# 3. Vérifier qu'au moins un point de spawn est visible
	var visible_points = get_visible_spawn_points()
	if visible_points.is_empty():
		return false
	
	# 4. Vérifier le cooldown de spawn
	var current_time = Time.get_ticks_msec() / 1000.0
	var spawn_interval = 1.0 #StressManager.get_spawn_interval() if StressManager else 1.0
	var actual_interval = max(spawn_interval, min_spawn_cooldown)
	
	if current_time - last_spawn_time < actual_interval:
		return false
	
	return true


## Récupère les points de spawn visibles par le joueur
func get_visible_spawn_points() -> Array[Node3D]:
	var visible_points: Array[Node3D] = []
	
	for point in spawn_points:
		if is_point_visible(point.global_position):
			visible_points.append(point)
	
	return visible_points


## Vérifie si un point est visible (dans le FOV et pas bloqué)
func is_point_visible(point_pos: Vector3) -> bool:
	# Vérifier que la caméra est assignée
	if not camera:
		return false
	
	# 1. Vérifier la distance minimale
	var distance_to_point = camera.global_position.distance_to(point_pos)
	if min_spawn_distance > 0 and distance_to_point < min_spawn_distance:
		return false
	
	# 2. Vérifier la distance maximale
	if max_spawn_distance > 0 and distance_to_point > max_spawn_distance:
		return false
	
	# 3. Vérifier le frustum de la caméra
	if not camera.is_position_in_frustum(point_pos):
		return false
	
	# 4. Vérifier l'angle supplémentaire si fov_angle > 0
	if fov_angle > 0:
		var camera_pos = camera.global_position
		var dir_to_point = (point_pos - camera_pos).normalized()
		var camera_forward = -camera.global_transform.basis.z
		var angle = camera_forward.angle_to(dir_to_point)
		if angle > deg_to_rad(fov_angle):
			return false
	
	# 5. Vérifier les obstacles avec un raycast
	return not is_obstructed(point_pos)


## Vérifie si la vue vers un point est bloquée par un obstacle
func is_obstructed(point_pos: Vector3) -> bool:
	# Vérifier que space_state est initialisé
	if not space_state:
		space_state = get_world_3d().direct_space_state
		if not space_state:
			return false
	
	var query = PhysicsRayQueryParameters3D.new()
	query.from = camera.global_position
	query.to = point_pos
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = collision_mask
	
	# Exclure le spawner lui-même et ses enfants
	var exclude = [self]
	for child in get_children():
		exclude.append(child)
	query.exclude = exclude
	
	var result = space_state.intersect_ray(query)
	if result:
		# Si on touche quelque chose avant d'atteindre le point, c'est bloqué
		var hit_distance = result.position.distance_to(camera.global_position)
		var point_distance = point_pos.distance_to(camera.global_position)
		return hit_distance < point_distance - 0.1  # Petite marge
	
	return false


## Spawn un nouveau monstre
func spawn_monster() -> void:
	# Supprimer l'ancien monstre s'il existe encore
	if current_monster and is_instance_valid(current_monster):
		current_monster.queue_free()
		current_monster = null
	
	var visible_points = get_visible_spawn_points()
	if visible_points.is_empty():
		return
	
	# Choisir un point de spawn aléatoire parmi les points visibles
	var spawn_point = visible_points[randi() % visible_points.size()]
	var base_position = spawn_point.global_position
	
	# Appliquer le multiplicateur de distance basé sur le stress
	var distance_multiplier =  1 #StressManager.get_distance_multiplier() if StressManager else 1.0
	var spawn_pos = camera.global_position.lerp(base_position, distance_multiplier)
	
	# Vérifier que la position de spawn est valide
	if max_spawn_distance > 0 and spawn_pos.distance_to(camera.global_position) > max_spawn_distance:
		spawn_pos = camera.global_position + (spawn_pos - camera.global_position).normalized() * max_spawn_distance
	
	# Créer le monstre
	var monster = monster_scene.instantiate()
	add_child(monster)
	monster.global_position = spawn_pos
	
	# Appliquer la taille basée sur le stress
	# if StressManager:
	# 	monster.scale = StressManager.get_monster_scale()
	
	# Configurer la durée de vie
	monster.lifespan = monster_lifespan
	
	# Stocker la référence au monstre actuel
	current_monster = monster
	
	# Mettre à jour le temps du dernier spawn
	last_spawn_time = Time.get_ticks_msec() / 1000.0
	
	# print("Monstre spawné à ", spawn_pos, " avec stress: ", StressManager.stress if StressManager else 0)


## Ajoute un point de spawn dynamiquement
func add_spawn_point(point: Node3D) -> void:
	spawn_points.append(point)


## Retire un point de spawn
func remove_spawn_point(point: Node3D) -> void:
	spawn_points.erase(point)


## Réinitialise le spawner
func reset() -> void:
	# Supprimer le monstre actuel
	if current_monster and is_instance_valid(current_monster):
		current_monster.queue_free()
	current_monster = null
	
	# Réinitialiser le stress
	# if StressManager:
	# 	StressManager.reset_stress()
	
	last_spawn_time = 0.0
