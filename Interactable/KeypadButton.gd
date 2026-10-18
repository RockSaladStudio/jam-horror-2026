@tool
class_name KeypadButton
extends Interactable

## Une touche physique du digicode. On la vise, on appuie sur "interact",
## elle previent le Keypad parent via son signal.

signal pressed_key(key: String)

## Caractere envoye au Keypad : "0".."9", "C" (effacer) ou "E" (valider).
@export var key: String = "0":
	set(value):
		key = value
		_refresh_label()

@export var press_depth: float = 0.008
@export var press_duration: float = 0.07

var _rest_position: Vector3
var _tween: Tween

func _ready() -> void:
	_rest_position = position
	_refresh_label()

func _refresh_label() -> void:
	var label := get_node_or_null(^"Label") as Label3D
	if label:
		label.text = key

func get_interaction_text() -> String:
	match key:
		Keypad.KEY_CLEAR:
			return "effacer"
		Keypad.KEY_ENTER:
			return "valider"
		_:
			return "taper %s" % key

func interact() -> void:
	pressed_key.emit(key)
	_animate_press()

# petit enfoncement de la touche, purement visuel
func _animate_press() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
		position = _rest_position
	_tween = create_tween()
	_tween.tween_property(self, ^"position", _rest_position - basis.z * press_depth, press_duration)
	_tween.tween_property(self, ^"position", _rest_position, press_duration)
