extends Node2D
@export var speed = 250


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += Vector2(speed * delta,0)
<<<<<<< HEAD
=======

func setVisible(visible: bool):
	$DebugSprite2D.visible=visible
	
>>>>>>> 536c0b8 (implement dev mode)
