extends Area2D
class_name CoinPurse

signal get_coin

@export var open_sprite: Sprite2D
@export var closed_sprite: Sprite2D

var locked: bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_enter)
	mouse_exited.connect(_on_mouse_exit)
	input_event.connect(_on_input_event)
	open_sprite.hide()
	closed_sprite.show()

func _on_mouse_enter() -> void:
	if locked == false:
		open_sprite.show()
		closed_sprite.hide()

func _on_mouse_exit() -> void:
	open_sprite.hide()
	closed_sprite.show()

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if locked:
		return
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		get_coin.emit()
		locked = true
