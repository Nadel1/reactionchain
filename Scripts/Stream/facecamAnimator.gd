extends Node
class_name FacecamAnimator

func move(direction : RT.Direction):
	$Movement.play("shift_"+RT.dirToStr(direction))

func react(emotion : RT.Emotion):
	$Movement.play("react_"+RT.emoteToStr(emotion))
