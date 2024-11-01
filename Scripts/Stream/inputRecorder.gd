extends Node

var recording = []
var timeSinceLastInput = 0.0
var record = true

func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	if Global.inputHandler == null: return
	if record:
		if Input.is_action_just_pressed("ui_end"):
			record = false
			Global.recordings.append(recording)
			return
		var input = Global.inputHandler.getInput()
		timeSinceLastInput += delta
		if(input[1]):
			recording.append([input[0], timeSinceLastInput])
			$"../CurrentInputLabel".text = str(input[0])
			#print(str(input[0]) + ", after " + str(timeSinceLastInput) + "s")
			timeSinceLastInput = 0
	pass
