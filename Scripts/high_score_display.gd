extends Node2D

var time = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayerHighScore.play("displayHighScore")

func _process(delta: float) -> void:
	time += delta * 4
	if time > 2*PI: time -= 2*PI
	var magnitude = 0.4-(1/log(max(10,Global.highScore/10)))
	rotation = sin(time) * PI/8.0 * max(0,magnitude)
