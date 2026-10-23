extends Control

## Ecran de fin : SAFE quand le joueur passe la porte de sortie.

const MAIN_MENU_PATH := "res://Menu/Menu.tscn"

## Bloque la pause pendant l'ecran de fin, sinon elle relancerait la partie derriere.
@export var pause_menu: PauseMenu

func _ready() -> void:
	visible = false

func show_victory() -> void:
	if visible:
		return
	if pause_menu:
		pause_menu.can_pause = false
	get_tree().paused = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	%BackButton.grab_focus()

func _on_victory_zone_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		show_victory()

func _on_back_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
