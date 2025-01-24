extends Node2D

@export var animator : AnimationPlayer
@export var donationProgress : StatBar
@onready var viewersActual = Global.score
@onready var viewersDisplayed = viewersActual
@onready var progressDisplayed = float(viewersActual) / Global.nextDonationViewerCount
var time = 0.0

func _process(delta: float) -> void:
	viewersDisplayed = lerpf(viewersDisplayed, viewersActual, delta)
	progressDisplayed = lerpf(progressDisplayed, float(viewersActual) / Global.nextDonationViewerCount, 5 * delta)
	updateDisplay()
	
	#time += delta * 4
	#if time > 2*PI: time -= 2*PI
	#var magnitude = 0.4-(1/log(max(10,viewersDisplayed/10)))
	#rotation = sin(time) * PI/8.0 * max(0,magnitude)

func updateDisplay():
	var viewerAmount = int(viewersDisplayed)
	var displayedViewers=str(viewerAmount)
	if viewerAmount>1000 and viewerAmount<1000000:
		displayedViewers=str(viewerAmount/1000)+"."+str((viewerAmount%1000)/100)
		displayedViewers=str(displayedViewers)+"k"
	elif viewerAmount>1000000:
		displayedViewers=str(viewerAmount/1000000)+"."+str((viewerAmount%1000000)/100000)
		displayedViewers=str(displayedViewers)+"m"
	$Label.text=str(displayedViewers)
	donationProgress.setValue(progressDisplayed)
	$Warning.play("warning" if viewersDisplayed < 10 else "default")

func _on_viewer_update_timeout() -> void:
	if viewersActual < Global.score:
		animator.play("increase")
	if viewersActual > Global.score:
		animator.play("decrease")
	viewersActual = Global.score

func _on_score_anim_animation_finished(_anim_name: StringName) -> void:
	if abs(viewersDisplayed - viewersActual) > 10:
		animator.play()
