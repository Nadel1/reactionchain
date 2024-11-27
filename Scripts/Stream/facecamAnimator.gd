extends Node2D

func move(direction : RT.Direction):
	$Movement.play("shift_"+RT.dirToStr(direction))

func react(emotion : RT.Emotion):
	if emotion==RT.Emotion.NONE: return
	$Head/Face.play(RT.emoteToStr(emotion))

func _ready():
	$Head/Face.play("default")

func _on_face_animation_finished() -> void:
	$Head/Face.play("default")
