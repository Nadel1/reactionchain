extends Node2D

func init(_streamerIndex : int, streamerSeed : int): #TODO: Make this randomize the streamer sprites too
	var hue = (rand_from_seed(streamerSeed + Global.mainSeed)[0]%1000)/1000.0
	var value = (rand_from_seed(streamerSeed + 10 + Global.mainSeed)[0]%1000)/1000.0
	value = 1.0 - value * value
	$Background.color = Color.from_hsv(hue, 0.8, value)

func move(direction : RT.Direction):
	$MovementRevert.start()
	$Movement.play("shift_"+RT.dirToStr(direction))

func react(emotion : RT.Emotion):
	$ReactionRevert.start()
	$Head/Face.play(RT.emoteToStr(emotion))

func _ready():
	$Head/Face.play("default")
	$DonationReaction.hide()

func _on_face_animation_finished() -> void:
	$Head/Face.play("default")

func _on_reaction_revert_timeout() -> void:
	$Head/Face.play("default")

func _on_movement_revert_timeout() -> void:
	$Movement.play("RESET")
	
func donationReaction(positive:bool):
	$DonationReaction.show()
	Global.inputRecorder.appendDonationReaction(positive)
	if positive:
		$DonationReaction.play("appreciate")
	else:
		$DonationReaction.play("fail")


func _on_donation_reaction_animation_finished() -> void:
	$DonationReaction.hide()
