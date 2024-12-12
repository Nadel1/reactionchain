extends Node2D
class_name GenericPrompt

@export var speed = 250

func _physics_process(delta: float) -> void:
	position += Vector2(speed * delta,0)

func _on_death_timer_timeout() -> void:
	call_deferred("queue_free")
