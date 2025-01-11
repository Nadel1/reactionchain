extends Node2D

@export var animator : AnimationPlayer
@onready var viewersActual = Global.score
@onready var viewersDisplayed = viewersActual
var time = 0.0

func _process(delta: float) -> void:
	viewersDisplayed = lerpf(viewersDisplayed, viewersActual, delta)
	$Label.text = "Viewers: " + str(int(viewersDisplayed))
	
	#time += delta * 4
	#if time > 2*PI: time -= 2*PI
	#var magnitude = 0.4-(1/log(max(10,viewersDisplayed/10)))
	#rotation = sin(time) * PI/8.0 * max(0,magnitude)

func _on_viewer_update_timeout() -> void:
	if viewersActual < Global.score:
		animator.play("increase")
	if viewersActual > Global.score:
		animator.play("decrease")
	viewersActual = Global.score

func _on_score_anim_animation_finished(_anim_name: StringName) -> void:
	if abs(viewersDisplayed - viewersActual) > 10:
		animator.play()
