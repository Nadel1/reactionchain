extends Node2D

var textsPositive = [
	"Wow!",
	"Great!",
	"Sick!",
	"Yeah!"
]
var textsEh = [
	"Okay",
	"Aight",
	"Good",
	"Fine"
]
var textsNegative = [
	"What?",
	"Oof!",
	"Ouch!",
	"Yuck!"
]
var velocity : Vector2
const gravity = Vector2(0.0,500.0)

func _ready() -> void:
	velocity = Vector2(randf_range(-125.0,125.0), randf_range(-250.0,0.0))

func setText(score : int): # 0 -> bad, 1 -> eh, 2 -> great
	var newText = ""
	if score == 2:
		newText = textsPositive.pick_random()
		$Text.modulate = Color.LIME
	elif score == 1:
		newText = textsEh.pick_random()
		$Text.modulate = Color.ORANGE
	elif score == 0:
		newText = textsNegative.pick_random()
		$Text.modulate = Color.RED
	
	$Text.text = "[center]" + newText + "[/center]"

func _process(delta: float) -> void:
	velocity += gravity * delta
	position += velocity * delta
	modulate = lerp(Color.TRANSPARENT, Color.WHITE, $DeathTimer.time_left/$DeathTimer.wait_time)
	scale = lerp(scale, Vector2(2,2), delta * 10)

func _on_death_timer_timeout() -> void:
	call_deferred("queue_free")
