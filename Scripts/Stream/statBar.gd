extends Node

var fullPos : float
var emptyPos : float
var length : float

func _ready() -> void:
	fullPos = $Bar.position.y
	length = $Bar.size.y
	emptyPos = fullPos + length


func setValue(value):
	value = clampf(value, 0, 1)
	if fullPos == null:
		_ready()
	$Bar.position.y = lerpf(emptyPos, fullPos, value)
	$Bar.size.y = lerpf(0, length, value)
