extends Control

const MAIN_MENU_PATH := "res://Menu/Menu.tscn"

var can_pause := true

func _ready() -> void:
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if can_pause and event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause() -> void:
	var paused := not get_tree().paused
	get_tree().paused = paused
	visible = paused
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED

func _on_play_button_pressed() -> void:
	toggle_pause()

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	visible = false
	can_pause = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
