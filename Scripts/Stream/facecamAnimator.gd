extends Node2D

func move(direction : RT.Direction):
	$Movement.play("shift_"+RT.dirToStr(direction))

func react(emotion : RT.Emotion):
	$Head/Face.play(emotion)
