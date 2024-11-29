extends Node2D

func init(seed : int): #TODO: Make this randomize the streamer sprites too
	var hue = (rand_from_seed(seed + Global.videoSeed)[0]%100)/100.0
	$Background.color = Color.from_hsv(hue, 0.8, 0.8)

func move(direction : RT.Direction):
	$MovementRevert.start()
	$Movement.play("shift_"+RT.dirToStr(direction))

func react(emotion : RT.Emotion):
	$ReactionRevert.start()
	$Head/Face.play(RT.emoteToStr(emotion))

func _ready():
	$Head/Face.play("default")

func _on_face_animation_finished() -> void:
	$Head/Face.play("default")

func _on_reaction_revert_timeout() -> void:
	$Head/Face.play("default")

func _on_movement_revert_timeout() -> void:
	$Movement.play("RESET")
