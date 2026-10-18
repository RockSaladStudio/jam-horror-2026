extends RayCast3D

const LABEL_GROUP := &"interaction_label"

@export var action: StringName = &"interact"

var _current: Interactable
var _label: Label
var _displayed_text: String = ""

func _ready() -> void:
	_label = get_tree().get_first_node_in_group(LABEL_GROUP) as Label
	if not _label:
		push_warning("Interaction : aucun Label dans le groupe %s." % LABEL_GROUP)
	_set_interaction_text("")

func _process(_delta: float) -> void:
	var target := get_collider() as Interactable

	if is_colliding() and target:
		_current = target
		if Input.is_action_just_pressed(action):
			target.interact()
		_set_interaction_text(target.get_interaction_text())
	elif _current:
		_current = null
		_set_interaction_text("")

func _set_interaction_text(text: String) -> void:
	if not _label or text == _displayed_text:
		return
	_displayed_text = text

	if text.is_empty():
		_label.visible = false
	else:
		_label.text = "[%s] %s" % [_action_key_name(), text]
		_label.visible = true

func _action_key_name() -> String:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey:
			if event.physical_keycode != 0:
				return event.as_text_physical_keycode()
			return event.as_text_keycode()
	return "?"
