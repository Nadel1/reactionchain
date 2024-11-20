extends Node

var recording = []
var timeSinceLastInput = 0.0
var recordInputs = true
var streamer

func setStreamer(newStreamer):
	streamer=newStreamer

func stopRecording():
	recordInputs = false
	Global.recordings.append(recording)


func _physics_process(delta: float) -> void:
	if Global.inputHandler == null: return
	if recordInputs:
		var input = Global.inputHandler.getInput()
		timeSinceLastInput += delta
		if(input[1]):
			recording.append([input[0], timeSinceLastInput])
			timeSinceLastInput = 0
			streamer.move(input[0])
	pass
