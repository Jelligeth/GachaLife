extends CanvasLayer
class_name UI

signal lock_in
signal start_over

@export var new_element_scene: PackedScene
@export_category("Nodes")
@export var start_screen: PanelContainer
@export var credits: Panel
@export var coins_text: RichTextLabel
@export var reward_screen: PanelContainer
@export var reward_label: Label
@export var reward_text: Label
@export var element_list: VBoxContainer
@export var discard_button: Button
@export var restart_button: Button
@export var end_screen: PanelContainer
@export var end_list: VBoxContainer
@export_category("Audio")
@export var open_ball_audio: AudioStreamPlayer
@export var lock_audio: AudioStreamPlayer
@export var discard_audio: AudioStreamPlayer
@export var win_audio: AudioStreamPlayer

func _ready() -> void:
	reward_screen.hide()
	credits.hide()
	end_screen.hide()
	start_screen.show()

func set_coins_text(amount: int) -> void:
	coins_text.text = str(amount)

func open_ball(label: String, text: String) -> void:
	open_ball_audio.play()
	reward_text.visible_ratio = 0
	reward_label.text = label
	reward_text.text = text
	reward_screen.show()
	var tween = create_tween()
	tween.tween_property(reward_text, "visible_ratio", 1, 0.5)

func add_locked_element(label: String, text: String) -> void:
	var new_element: ListElement = new_element_scene.instantiate()
	element_list.add_child(new_element)
	new_element.set_text(label + " " + text)

func disable_discard_button(disabled: bool) -> void:
	discard_button.disabled = disabled

func end_game(true_end: bool) -> void:
	if true_end:
		restart_button.hide()
	win_audio.play()
	var list = element_list.get_children()
	if list.size() == 1:
		var label = Label.new()
		end_list.add_child(label)
		label.text = "only emptiness remains..."
	else:
		for item in list:
			item.reparent(end_list)
			if item is ListElement:
				item.disable_autowrap()
	end_screen.show()

func show_credits() -> void:
	credits.show()

func _on_button_lock_pressed() -> void:
	lock_audio.play()
	reward_screen.hide()
	lock_in.emit()

func _on_button_discard_pressed() -> void:
	discard_audio.play()
	reward_screen.hide()

func _on_restart_button_pressed() -> void:
	reward_screen.hide()
	credits.hide()
	end_screen.hide()
	var list = end_list.get_children()
	for item in list:
		item.queue_free()
	lock_audio.play()
	start_over.emit()


func _on_start_button_pressed() -> void:
	win_audio.play()
	#lock_audio.play()
