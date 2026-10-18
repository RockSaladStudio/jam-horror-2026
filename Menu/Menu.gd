extends Control

const GAME_SCENE := "res://main.tscn"
const ICON_VOLUME_ON := preload("res://Menu/icons/volume_on.svg")
const ICON_VOLUME_OFF := preload("res://Menu/icons/volume_off.svg")

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton
@onready var volume_button: Button = %VolumeButton
@onready var volume_slider: HSlider = %VolumeSlider

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	quit_button.visible = not OS.has_feature("web")

	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	volume_button.pressed.connect(AudioSettings.toggle_mute)
	volume_slider.value_changed.connect(AudioSettings.set_volume)
	AudioSettings.changed.connect(_refresh_volume_ui)

	_refresh_volume_ui()
	play_button.grab_focus()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_quit_pressed() -> void:
	get_tree().quit()

func _refresh_volume_ui() -> void:
	var silent := AudioSettings.is_silent()
	volume_button.icon = ICON_VOLUME_OFF if silent else ICON_VOLUME_ON
	volume_button.tooltip_text = "Activer le son" if silent else "Couper le son"
	volume_slider.set_value_no_signal(0.0 if silent else AudioSettings.volume)
