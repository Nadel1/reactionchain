extends Node2D
class_name StatBar

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
	$Bar.position.y = ceil(lerpf(emptyPos, fullPos, value))
	$Bar.size.y = floor(lerpf(0, length, value))
