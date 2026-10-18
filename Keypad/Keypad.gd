class_name Keypad
extends Node3D

signal code_accepted(code: String)
signal code_rejected(code: String)
signal key_pressed(key: String)
signal entry_changed(entry: String)

const KEY_CLEAR := "C"
const KEY_ENTER := "E"

@export var code: String = "1947"
@export var mask_entry: bool = false
@export var feedback_duration: float = 1.2
@export var idle_text: String = "----"

@export_group("Sons")
@export var press_sound: AudioStream
@export var accept_sound: AudioStream
@export var reject_sound: AudioStream

@export_group("Couleurs")
@export var idle_color: Color = Color(0.35, 1.0, 0.45)
@export var accept_color: Color = Color(0.35, 1.0, 0.45)
@export var reject_color: Color = Color(1.0, 0.25, 0.2)

var entry: String = ""

var _busy: bool = false

@onready var _display: Label3D = $Display
@onready var _keys: Node3D = $Keys
@onready var _audio: AudioStreamPlayer3D = get_node_or_null(^"Audio")
@onready var _status_light: OmniLight3D = get_node_or_null(^"StatusLight")

func _ready() -> void:
	for child in _keys.get_children():
		if child is KeypadButton:
			child.pressed_key.connect(_on_key_pressed)
	_refresh_display()

func _on_key_pressed(key: String) -> void:
	if _busy:
		return

	key_pressed.emit(key)
	_play(press_sound)

	match key:
		KEY_CLEAR:
			entry = ""
			entry_changed.emit(entry)
			_refresh_display()
		KEY_ENTER:
			_submit()
		_:
			if entry.length() >= code.length():
				return
			entry += key
			entry_changed.emit(entry)
			_refresh_display()

func _submit() -> void:
	var attempt := entry
	entry = ""
	entry_changed.emit(entry)
	_busy = true

	if attempt == code:
		_display.text = "OK"
		_display.modulate = accept_color
		_flash(accept_color)
		_play(accept_sound)
		code_accepted.emit(attempt)
	else:
		_display.text = "ERR"
		_display.modulate = reject_color
		_flash(reject_color)
		_play(reject_sound)
		code_rejected.emit(attempt)

	await get_tree().create_timer(feedback_duration).timeout
	_busy = false
	_refresh_display()

func _refresh_display() -> void:
	_display.modulate = idle_color
	if entry.is_empty():
		_display.text = idle_text
	elif mask_entry:
		_display.text = "*".repeat(entry.length())
	else:
		_display.text = entry
	if _status_light:
		_status_light.visible = false

func _flash(color: Color) -> void:
	if not _status_light:
		return
	_status_light.light_color = color
	_status_light.visible = true

func _play(stream: AudioStream) -> void:
	if _audio and stream:
		_audio.stream = stream
		_audio.play()
