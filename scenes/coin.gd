extends Area2D
class_name Coin

@export var normal: Sprite2D
@export var flipped: Sprite2D

var is_flipped: bool = false

func _ready() -> void:
	normal.show()
	flipped.hide()

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()

func flip() -> void:
	if is_flipped:
		normal.show()
		flipped.hide()
		is_flipped = false
	else:
		normal.hide()
		flipped.show()
		is_flipped = true
