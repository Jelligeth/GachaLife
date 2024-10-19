extends Sprite2D

@export var ball_scene: PackedScene
@export var gacha_list: JSON
@export_category("Scene Nodes")
@export var ball_node: Node2D
@export var hole: Node2D
@export var knob: Area2D
@export var ball_detector: Area2D

var level_arrays: Array = []

var level_index: int = 0
var level_name: String = ""
var gacha_array: Array = []

var ball: RigidBody2D

func _ready() -> void:
	load_list()
	knob.input_event.connect(turn_knob)
	ball_detector.body_entered.connect(got_ball)

func load_list() -> void:
	level_arrays = gacha_list.data
	set_level()

func set_level() -> void:
	level_name = level_arrays[level_index][0]
	gacha_array = level_arrays[level_index][1]
	spawn_balls()
	level_index += 1

func spawn_balls() -> void:
	for item in gacha_array:
		var ball = ball_scene.instantiate()
		ball_node.add_child(ball)
		await get_tree().create_timer(0.1).timeout

func turn_knob(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var tween = create_tween()
		tween.tween_property(knob,"rotation", 180, 1)

func got_ball(body) -> void:
	ball = body
	ball.set_physics_process(false)
	ball.global_position = hole.global_position
