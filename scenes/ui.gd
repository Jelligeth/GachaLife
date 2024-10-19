extends CanvasLayer
class_name UI

signal lock_in

@export var new_element_scene: PackedScene
@export_category("Nodes")
@export var start_screen: PanelContainer
@export var coins_text: RichTextLabel
@export var reward_screen: PanelContainer
@export var reward_label: RichTextLabel
@export var reward_text: Label
@export var element_list: VBoxContainer
@export var discard_button: Button
@export var end_screen: PanelContainer
@export var end_list: VBoxContainer
@export var restart_button: Button


func _ready() -> void:
	reward_screen.hide()
	end_screen.hide()
	start_screen.show()

func set_coins_text(amount: int) -> void:
	coins_text.text = str(amount)

func open_ball(label: String, text: String) -> void:
	reward_label.text = label
	reward_text.text = text
	reward_screen.show()

func add_locked_element(label: String, text: String) -> void:
	var new_element: ListElement = new_element_scene.instantiate()
	element_list.add_child(new_element)
	new_element.set_text(label + " " + text)

func disable_discard_button(disabled: bool) -> void:
	discard_button.disabled = disabled

func end_game() -> void:
	var list = element_list.get_children()
	for item in list:
		item.reparent(end_list)
	end_screen.show()

func _on_button_lock_pressed() -> void:
	reward_screen.hide()
	lock_in.emit()

func _on_button_discard_pressed() -> void:
	reward_screen.hide()

func _on_end_button_pressed() -> void:
	get_tree().reload_current_scene()
