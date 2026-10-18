extends Node

signal changed

const SAVE_PATH := "user://settings.cfg"
const DEFAULT_VOLUME := 0.8

var volume: float = DEFAULT_VOLUME
var muted: bool = false

func _ready() -> void:
	_load()
	_apply()

func set_volume(value: float) -> void:
	volume = clampf(value, 0.0, 1.0)
	if volume > 0.0:
		muted = false
	_commit()

func toggle_mute() -> void:
	if is_silent():
		muted = false
		if volume <= 0.0:
			volume = DEFAULT_VOLUME
	else:
		muted = true
	_commit()

func is_silent() -> bool:
	return muted or volume <= 0.0

func _commit() -> void:
	_apply()
	_save()
	changed.emit()

func _apply() -> void:
	var bus := AudioServer.get_bus_index(&"Master")
	AudioServer.set_bus_volume_linear(bus, volume)
	AudioServer.set_bus_mute(bus, is_silent())

func _load() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	volume = clampf(config.get_value("audio", "volume", DEFAULT_VOLUME), 0.0, 1.0)
	muted = config.get_value("audio", "muted", false)

func _save() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "volume", volume)
	config.set_value("audio", "muted", muted)
	config.save(SAVE_PATH)
