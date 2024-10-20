extends HBoxContainer
class_name ListElement

@export var label: Label

func set_text(text: String) -> void:
	label.text = text
	var tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1, 1)


func disable_autowrap() -> void:
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
