class_name Blindfold
extends MeshInstance3D

var lift_speed: float = 0.5
var drop_speed: float = 2.0

var current_progress: float = 0.0


func _init() -> void:
	visible = true


func _ready() -> void:
	# S'enregistre auprès du StressManager pour qu'il sache quand le bandeau est baissé
	StressManager.blindfold = self


func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		current_progress += lift_speed * delta
	else:
		current_progress -= drop_speed * delta

	current_progress = clamp(current_progress, 0.0, 1.0)

	# On met à jour le paramètre sur le Material Override
	if material_override:
		material_override.set_shader_parameter("blindfold_progress", current_progress)
