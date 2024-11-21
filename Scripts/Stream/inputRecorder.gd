extends Node
class_name InputRecorder

var recordingMovement = []
var recordingReaction =[]
var timeSinceLastInput = 0.0
var recordInputs = true
var streamer

func setStreamer(newStreamer):
	streamer=newStreamer

func stopRecording():
	recordInputs = false
	Global.recordingsMovement.append(recordingMovement)
	Global.recordingsReaction.append(recordingReaction)
	


func _physics_process(delta: float) -> void:
	if Global.inputHandler == null: return
	if recordInputs:
		var input = Global.inputHandler.getInput()
		timeSinceLastInput += delta
		if(input[1]):
			recordingMovement.append([input[0], timeSinceLastInput])
			timeSinceLastInput = 0
			streamer.move(input[0])
	pass

func appendRecordedReaction(countMovements,reaction):
	recordingReaction.append([countMovements,reaction])
func _on_eol_stop_playing_music_timer_timeout() -> void:
	pass # Replace with function body.
