extends Node2D
class_name GenericPrompt

@export var speed = 250
@export var deleteOnFreeze = false
var fast = false
var snippetIndex = -1
var launched = false
var velocity : Vector2
var angularVelocity = 0.0
const gravity = Vector2(0.0,1000.0)

func _ready() -> void:
	Global.pause.connect(freeze)
	snippetIndex = Global.arrowSnippetIndex

func _physics_process(delta: float) -> void:
	position += Vector2(speed * delta,0)
	if launched:
		position += velocity * delta
		velocity += gravity * delta
		rotation += angularVelocity * delta

func _on_death_timer_timeout() -> void:
	call_deferred("queue_free")

func freeze(depth : int):
	if !fast and depth == Global.currentStreamIndex:
		speed = 0
	if deleteOnFreeze:
		call_deferred("queue_free")

func setFast(value : bool):
	fast = value
	if fast:
		speed = speed * Global.fastPromptMult
