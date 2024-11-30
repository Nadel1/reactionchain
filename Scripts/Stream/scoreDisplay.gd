extends Node2D

@onready var viewersActual = Global.score
@onready var viewersDisplayed = viewersActual
var time = 0.0

func _process(delta: float) -> void:
	viewersDisplayed = lerpf(viewersDisplayed, viewersActual, delta)
	$Label.text = "Viewers: " + str(int(viewersDisplayed))
	
	time += delta * 4
	if time > 2*PI: time -= 2*PI
	var magnitude = 0.4-(1/log(max(10,viewersDisplayed/10)))
	rotation = sin(time) * PI/8.0 * max(0,magnitude)

func _on_viewer_update_timeout() -> void:
	viewersActual = Global.score
