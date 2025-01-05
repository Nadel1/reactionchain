extends Node2D

var preparingYap = false
var yapping = false
var layerIndex : int

func _ready():
	Global.pastEvent.connect(pastEvent)
	Global.pause.connect(pause)
	Global.resume.connect(resume)
	$DonationReaction.hide()
	$Head/Face.play("default")
	
func init(_streamerIndex : int, streamerSeed : int): #TODO: Make this randomize the streamer sprites too
	layerIndex = streamerSeed # Awful naming but the seed is the layer in this case
	var hue = (rand_from_seed(streamerSeed + Global.mainSeed)[0]%1000)/1000.0
	var value = (rand_from_seed(streamerSeed + 10 + Global.mainSeed)[0]%1000)/1000.0
	value = 1.0 - value * value
	$Background.color = Color.from_hsv(hue, 0.8, value)

func move(direction : RT.Direction):
	if !preparingYap:
		$MovementRevert.start()
		$Movement.play("shift_"+RT.dirToStr(direction))
		if !yapping:
			$Head.scale = Vector2(1,1)
			$BodyAnimation.play(RT.dirToStr(direction))

func react(emotion : RT.Emotion):
	$ReactionRevert.start()
	$Head/Face.play(RT.emoteToStr(emotion))

func event(): #TODO: Add argument to enable more events
	preparingYap = true
	$EventStart.start()
	$Movement.play("prepare_yap")
	$BodyAnimation.play("prepare_yap")

func pastEvent(event : Event):
	if event.startLayer == layerIndex:
		event()

func pause(depth):
	if depth > layerIndex:
		$Movement.pause()
		$BodyAnimation.pause()
		$ReactionRevert.paused = true
		$MovementRevert.paused = true

func resume(depth):
	if depth == layerIndex:
		yapping = false
		$BodyAnimation.play("RESET")
	if depth > layerIndex:
		$Movement.play()
		$BodyAnimation.play()
		$ReactionRevert.paused = false
		$MovementRevert.paused = false

func _on_face_animation_finished() -> void:
	$Head/Face.play("default")

func _on_reaction_revert_timeout() -> void:
	$Head/Face.play("default")

func _on_movement_revert_timeout() -> void:
	if !preparingYap and !yapping:
		$Movement.play("RESET")
		$BodyAnimation.play("RESET")
	
func donationReaction(positive:bool,recorded:bool=true):
	$DonationReaction.show()
	if recorded:
		Global.inputRecorder.appendDonationReaction(positive)
	if positive:
		$DonationReaction.play("appreciate")
	else:
		$DonationReaction.play("fail")


func _on_donation_reaction_animation_finished() -> void:
	$DonationReaction.hide()

func _on_movement_animation_finished(anim_name: StringName) -> void:
	if yapping:
		$Movement.play("yap")
	if preparingYap:
		preparingYap = false
		yapping = true
		$Movement.play("yap")
		$BodyAnimation.play("yap")

func _on_event_start_timeout() -> void:
	pass
	#Global.pauseStream(layerIndex)

func _on_body_animation_animation_finished(anim_name: StringName) -> void:
	if yapping:
		$BodyAnimation.play("yap")
