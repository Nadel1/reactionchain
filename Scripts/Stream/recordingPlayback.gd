extends Node

@export var index = 0
var playing = false
var timeSinceLastInput = 0.0
var inputIndex = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	if playing:
		if Global.recordings.size() <= index || Global.recordings[index].size() <= inputIndex:
			playing = false
			#print("End playback")
			return
		timeSinceLastInput += delta
		if Global.recordings[index][inputIndex][1] == timeSinceLastInput:
			var input = Global.recordings[index][inputIndex][0]
			$"../RecordedInputLabel".text = str(input)
			#print(str(input) + ", after " + str(timeSinceLastInput) + "s")
			timeSinceLastInput = 0
			inputIndex += 1
	else:
		if Input.is_action_just_pressed("ui_accept"):
			#print("Begin playback")
			playing = true;
	pass
