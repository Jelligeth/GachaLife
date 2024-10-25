extends Node2D
class_name GachaMachine

signal turned_knob
signal took_ball
signal show_credits
signal return_coin

@export var ball_scene: PackedScene

@export_category("Scene Nodes")
@export var machine: Sprite2D
@export var machine_label: Label
@export var ball_node: Node2D
@export var knob: Area2D
@export_category("Audio")
@export var audio_knob_turn: AudioStreamPlayer
@export var audio_knob_stop: AudioStreamPlayer
@export var audio_coinslot: AudioStreamPlayer

var turning: bool = false
var spawning: bool = false

var ball_count: int = 0

var has_ball: bool = false
var got_ball: RigidBody2D

var coin: Coin = null
var paid: bool = false

func _ready() -> void:
	knob.rotation = 0

func set_label(text: String) -> void:
	machine_label.text = text
	
func show_machine(showing: bool) -> void:
	var dest: Vector2 = Vector2.ZERO
	if not showing:
		dest = Vector2(0,-2000)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(machine, "position", dest, 1)
	await tween.finished

func spawn_balls(amount: int) -> void:
	spawning = true
	ball_count = amount
	for i in ball_count:
		got_ball = ball_scene.instantiate()
		ball_node.add_child(got_ball)
		got_ball.rotate(randf_range(0, PI*2))
		await get_tree().create_timer(0.1).timeout
	got_ball = null
	spawning = false

func turn_knob() -> void:
	turning = true
	if knob.rotation == 0:
		turned_knob.emit()
	audio_knob_turn.play()
	await tween_rotation(knob,knob.rotation + PI*0.5, 0.5)
	if floori(knob.rotation) >= floori(2*PI):
		knob.rotation = 0
		paid = false
	turning = false

func wiggle() -> void:
	if turning:
		return
	turning = true
	audio_knob_stop.play()
	var original_rotation = knob.rotation
	await tween_rotation(knob, original_rotation + 0.1, 0.05)
	await tween_rotation(knob, original_rotation - 0.1, 0.1)
	await tween_rotation(knob, original_rotation, 0.05)
	turning = false

func empty() -> void:
	var balls = ball_node.get_children()
	for ball in balls:
		ball.queue_free()

func reset_level() -> void:
	if spawning: return
	empty()
	if paid or has_ball or got_ball:
		return_coin.emit()
	var tween = create_tween()
	got_ball = null
	turning = false
	tween.tween_property(knob, "rotation", 0, 0.1)
	spawn_balls(ball_count)

func shake() -> void:
	await tween_rotation(self, PI*0.05, 0.1)
	await tween_rotation(self, -PI*0.05, 0.1)
	await tween_rotation(self, PI*0.02, 0.1)
	await tween_rotation(self, -PI*0.02, 0.1)
	await tween_rotation(self, 0, 0.1)


func tween_rotation(what, angle: float, time: float) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(what, "rotation", angle, time)
	await tween.finished


func _on_gacha_knob_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not turning and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if not got_ball and paid and (knob.rotation == 0 or (knob.rotation > 0 and has_ball)):
			turn_knob()
		else:
			wiggle()

func _on_hole_body_entered(body: Node2D) -> void:
	if body is Ball:
		got_ball = body

func _on_hole_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if got_ball and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		took_ball.emit()
		got_ball.queue_free()
		ball_count -= 1
		got_ball = null

func _on_reset_level_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		reset_level()

func _on_credits_label_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		show_credits.emit()

func _on_coin_hole_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if coin and event is InputEventMouseButton:
		audio_coinslot.play()
		coin.queue_free()
		coin = null
		paid = true


func _on_coin_hole_area_entered(area: Area2D) -> void:
	if area is Coin:
		coin = area

func _on_coin_hole_area_exited(area: Area2D) -> void:
	if area is Coin:
		coin = null

func _on_window_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		shake()

func _on_knob_body_entered(body: Node2D) -> void:
	if body is Ball:
		has_ball = true

func _on_knob_body_exited(body: Node2D) -> void:
	if body is Ball:
		has_ball = false
