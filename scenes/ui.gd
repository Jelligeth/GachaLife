extends CanvasLayer
class_name UI

signal lock_in

@export var new_element_scene: PackedScene
@export_category("Nodes")
@export var start_screen: PanelContainer
@export var coins_text: RichTextLabel
@export var prize_element: MarginContainer
@export var prize_label: RichTextLabel
@export var prize_text: Label
@export var element_list: VBoxContainer
@export var discard_button: Button
@export var end_screen: PanelContainer
@export var end_list: VBoxContainer
@export var restart_button: Button


func _ready() -> void:
	prize_element.hide()
	end_screen.hide()
	start_screen.show()

func set_coins_text(amount: int) -> void:
	coins_text.text = str(amount)

func open_ball(label: String, text: String) -> void:
	prize_label.text = label
	prize_text.text = text
	prize_element.show()

func add_locked_element(label: String, text: String) -> void:
	var new_element: Label = new_element_scene.instantiate()
	element_list.add_child(new_element)
	new_element.text = label + " " + text

func disable_discard_button(disabled: bool) -> void:
	discard_button.disabled = disabled

func end_game() -> void:
	var list = element_list.get_children()
	for item in list:
		item.reparent(end_list)
	end_screen.show()

func _on_button_lock_pressed() -> void:
	prize_element.hide()
	lock_in.emit()

func _on_button_discard_pressed() -> void:
	prize_element.hide()

func _on_end_button_pressed() -> void:
	get_tree().reload_current_scene()
