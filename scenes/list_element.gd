extends HBoxContainer
class_name ListElement

@export var label: Label

func set_text(text: String) -> void:
	label.text = text
