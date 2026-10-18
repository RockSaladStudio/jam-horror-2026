class_name Door
extends Interactable

signal opened
signal closed
signal locked_attempt

@export var locked: bool = true
@export var animation_name: StringName = &"OpenDoor"

@export_group("Textes d'interaction")
@export var open_text: String = "ouvrir la porte"
@export var close_text: String = "fermer la porte"
@export var locked_text: String = "ouvrir la porte (verrouillee)"

var is_open: bool = false

@onready var _anim: AnimationPlayer = $AnimationPlayer

func get_interaction_text() -> String:
	if is_open:
		return close_text
	return locked_text if locked else open_text

func interact() -> void:
	if _anim.is_playing():
		return
	if is_open:
		close()
	elif locked:
		locked_attempt.emit()
	else:
		open()

func unlock(auto_open: bool = true) -> void:
	locked = false
	if auto_open:
		open()

func lock() -> void:
	locked = true

func open() -> void:
	if is_open or _anim.is_playing():
		return
	is_open = true
	_anim.play(animation_name)
	opened.emit()

func close() -> void:
	if not is_open or _anim.is_playing():
		return
	is_open = false
	_anim.play_backwards(animation_name)
	closed.emit()
