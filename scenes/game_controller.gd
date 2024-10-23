extends Node2D

@export var ui: UI
@export var gacha_list: JSON
@export var gacha_machine: GachaMachine
@export var coin_scene: PackedScene
@export var audio_coin: AudioStreamPlayer

var level_arrays: Array = []

var level_index: int = 0
var gacha_array: Array = []

var coin: Coin = null
var coin_count: int = 0

var level_label: String = ""
var level_result: String = ""

func _ready() -> void:
	level_arrays = gacha_list.data
	gacha_machine.took_ball.connect(open_ball)
	gacha_machine.show_credits.connect(show_credits)
	ui.lock_in.connect(lock_in)
	ui.start_over.connect(reload)
	ui.set_coins_text(coin_count)
	coin_count = floori((level_arrays.size() - 1) * 0.5)
	set_level()


func reload() -> void:
	coin_count = floori((level_arrays.size() - 1) * 0.5)
	level_index = 0
	ui.set_coins_text(coin_count)
	set_level()


func set_level() -> void:
	if level_index >= level_arrays.size():
		if level_arrays.size() == 0:
			game_over(true)
		else:
			game_over(false)
		return
	update_coin_count(1)
	await gacha_machine.show_machine(false)
	level_label = level_arrays[level_index][0]
	var machine_name = level_arrays[level_index][1]
	gacha_array = level_arrays[level_index][2]
	if gacha_array.size() == 0:
		gacha_array.append("entropy")
		level_arrays.remove_at(level_index)
	else:
		level_index += 1
	gacha_machine.empty()
	gacha_machine.set_label(machine_name)
	await gacha_machine.show_machine(true)
	await gacha_machine.spawn_balls(gacha_array.size())
	if coin_count > 0:
		ui.disable_discard_button(false)

func update_coin_count(amount: int) -> void:
	coin_count += amount
	ui.set_coins_text(coin_count)
	if coin_count == 0:
		ui.disable_discard_button(true)

func open_ball() -> void:
	var i = randi_range(0, gacha_array.size() - 1)
	level_result = gacha_array[i]
	ui.open_ball(level_label, level_result)
	gacha_array.remove_at(i)
	if gacha_array.is_empty():
		ui.disable_discard_button(true)

func lock_in() -> void:
	ui.add_locked_element(level_label, level_result)
	gacha_machine.empty()
	set_level()

func show_credits() -> void:
	ui.show_credits()

#Show end game screen
func game_over(end: bool) -> void:
	ui.end_game(end)


func get_coin() -> void:
	audio_coin.play()
	coin = coin_scene.instantiate()
	add_child(coin)
	update_coin_count(-1)
	
func _on_coin_purse_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if coin_count and coin == null and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		get_coin()
