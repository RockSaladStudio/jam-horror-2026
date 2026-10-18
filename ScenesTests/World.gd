extends Node3D

## Cablage de la scene de test : le digicode deverrouille la porte.

@onready var door: Door = $Door
@onready var keypad: Keypad = $Keypad

func _on_keypad_code_accepted(code: String) -> void:
	print("Code correct (%s) : la porte se deverrouille." % code)
	door.unlock()

func _on_keypad_code_rejected(code: String) -> void:
	print("Code refuse : %s" % code)

func _on_door_locked_attempt() -> void:
	print("La porte est verrouillee, il faut le code.")
