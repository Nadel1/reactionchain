extends Node
class_name InputHandler

enum ButtonInput {NONE, UP, RIGHT, DOWN, LEFT}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.inputHandler = self
	pass # Replace with function body.

func getInput(): # Returns the currently held button and whether it was first pressed just now
	if Input.is_action_pressed("ui_up"): return [ButtonInput.UP, Input.is_action_just_pressed("ui_up")]
	if Input.is_action_pressed("ui_right"): return [ButtonInput.RIGHT, Input.is_action_just_pressed("ui_right")]
	if Input.is_action_pressed("ui_down"): return [ButtonInput.DOWN, Input.is_action_just_pressed("ui_down")]
	if Input.is_action_pressed("ui_left"): return [ButtonInput.LEFT, Input.is_action_just_pressed("ui_left")]
	return [ButtonInput.NONE, false]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
