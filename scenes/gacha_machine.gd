extends Sprite2D
class_name GachaMachine

signal turned_knob
signal took_ball
signal show_credits

@export var ball_scene: PackedScene

@export_category("Scene Nodes")
@export var ball_node: Node2D
@export var hole: Node2D
@export var knob: Area2D
@export var ball_detector: Area2D
@export var audio_yep: AudioStreamPlayer2D
@export var audio_nope: AudioStreamPlayer2D

var can_turn: bool = true
var turning: bool = false
var ball_count: int = 0

var got_ball: RigidBody2D
var has_ball: bool = false

func _ready() -> void:
	knob.rotation = 0
	can_turn = true

func spawn_balls(amount: int) -> void:
	ball_count = amount
	for i in ball_count:
		got_ball = ball_scene.instantiate()
		ball_node.add_child(got_ball)
		got_ball.rotate(randf_range(0, PI*2))
		await get_tree().create_timer(0.1).timeout
	got_ball = null

func turn_knob() -> void:
	turning = true
	if knob.rotation > 0 and not has_ball:
		wiggle()
		turning = false
		return
	if knob.rotation == 0:
		turned_knob.emit()
	audio_yep.play()
	var tween = create_tween()
	tween.tween_property(knob,"rotation", knob.rotation + PI/2, 0.5)
	await tween.finished
	if floori(knob.rotation) >= floori(2*PI):
		knob.rotation = 0
	turning = false

func wiggle() -> void:
	audio_nope.play()
	var original_rotation = knob.rotation
	var tween = create_tween()
	tween.tween_property(knob, "rotation", knob.rotation + 0.05, 0.1)
	await tween.finished
	knob.rotation = original_rotation

func empty() -> void:
	var balls = ball_node.get_children()
	for ball in balls:
		ball.queue_free()

func reset_level() -> void:
	empty()
	var tween = create_tween()
	got_ball = null
	can_turn = true
	turning = false
	has_ball = false
	tween.tween_property(knob, "rotation", 0, 0.1)
	spawn_balls(ball_count)


func _on_gacha_knob_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not turning and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		if not got_ball and can_turn:
			turn_knob()
		else:
			wiggle()

func _on_hole_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if got_ball and event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		took_ball.emit()
		got_ball.queue_free()
		ball_count -= 1
		got_ball = null
		has_ball = false

func _on_reset_level_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		reset_level()

func _on_guts_ball_body_entered(body: Node2D) -> void:
	if body is Ball:
		got_ball = body

func _on_gacha_knob_body_entered(body: Node2D) -> void:
	if body is Ball:
		has_ball = true

func _on_credits_label_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		show_credits.emit()
