extends RigidBody2D
class_name Ball

@export var audio: AudioStreamPlayer2D

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1

func _on_body_entered(body: Node) -> void:
	if body is Ball:
		return
	audio.play()
