extends Sprite2D
class_name GachaMachine

signal turned_knob
signal took_ball

@export var ball_scene: PackedScene

@export_category("Scene Nodes")
@export var ball_node: Node2D
@export var hole: Node2D
@export var knob: Area2D
@export var ball_detector: Area2D

var got_ball: RigidBody2D
var can_turn: bool = true
var turning: bool = false

func _ready() -> void:
	knob.rotation = 0
	can_turn = true

func spawn_balls(amount: int) -> void:
	for i in amount:
		got_ball = ball_scene.instantiate()
		ball_node.add_child(got_ball)
		await get_tree().create_timer(0.1).timeout
	got_ball = null

func turn_knob() -> void:
	turning = true
	if knob.rotation == 0:
		turned_knob.emit()
	var tween = create_tween()
	tween.tween_property(knob,"rotation", knob.rotation + PI/2, 0.5)
	await tween.finished
	if floori(knob.rotation) >= floori(2*PI):
		knob.rotation = 0
	turning = false

func wiggle() -> void:
	var tween = create_tween()
	tween.tween_property(knob, "rotation", PI*0.05, 0.1)
	await tween.finished
	knob.rotation = 0

func empty() -> void:
	var balls = ball_node.get_children()
	for ball in balls:
		ball.queue_free()

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
		got_ball = null

func _on_hole_body_entered(body: Node2D) -> void:
	got_ball = body
