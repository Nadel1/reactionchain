extends Node2D
class_name GenericPrompt

@export var speed = 250
var snippetIndex = -1
var launched = false
var velocity : Vector2
const gravity = Vector2(0.0,500.0)

func _ready() -> void:
	Global.pause.connect(freeze)
	snippetIndex = Global.arrowSnippetIndex

func _physics_process(delta: float) -> void:
	position += Vector2(speed * delta,0)
	if launched:
		position += velocity * delta
		velocity += gravity * delta

func _on_death_timer_timeout() -> void:
	call_deferred("queue_free")

func freeze(depth : int):
	if depth == Global.currentStreamIndex:
		speed = 0

func setFast(fast : bool):
	if fast:
		speed = speed * Global.fastPromptMult
