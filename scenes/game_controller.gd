extends Node2D

@export var ui: UI
@export var gacha_list: JSON
@export var gacha_machine: GachaMachine

var level_arrays: Array = []

var level_index: int = 0
var gacha_array: Array = []

var coins: int = 9

var level_label: String = ""
var level_result: String = ""

func _ready() -> void:
	level_arrays = gacha_list.data
	gacha_machine.turned_knob.connect(turned_knob)
	gacha_machine.took_ball.connect(open_ball)
	gacha_machine.show_credits.connect(show_credits)
	ui.lock_in.connect(lock_in)
	ui.set_coins_text(coins)
	set_level()

func set_level() -> void:
	if level_index >= level_arrays.size():
		game_over()
		return
	update_coins(1)
	await show_machine(false)
	level_label = level_arrays[level_index][0]
	gacha_array = level_arrays[level_index][1]
	if gacha_array.size() <= 0:
		gacha_array.append("there's nothing left...")
	gacha_machine.empty()
	await show_machine(true)
	await gacha_machine.spawn_balls(gacha_array.size())
	ui.disable_discard_button(false)
	level_index += 1

func show_machine(showing: bool) -> void:
	var dest: Vector2 = Vector2.ZERO
	if not showing:
		dest = Vector2(0,-2000)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(gacha_machine, "position", dest, 1)
	await tween.finished

func turned_knob() -> void:
	if coins > 0:
		update_coins(-1)
		gacha_machine.can_turn = true
	else:
		game_over()

func update_coins(amount: int) -> void:
	coins += amount
	ui.set_coins_text(coins)
	if coins == 0:
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
func game_over() -> void:
	ui.end_game()
