extends Node
class_name InputRecorder

var recordingMovement = []
var recordingReaction = []
var recordingFails = []
var recordingChat = []
var timeSinceLastInput = 0.0
var timeSinceLastReaction = 0.0
var timeSinceLastFail = 0.0
var timeSinceLastMessage=0.0
var recordInputs = true
var streamer

func setStreamer(newStreamer):
	streamer=newStreamer

func _ready() -> void:
	Global.inputRecorder = self

func reactionFailed(packetDuration: float):
	recordingFails.append([timeSinceLastFail-packetDuration, packetDuration])
	timeSinceLastFail = 0.0

func stopRecording():
	recordInputs = false
	Global.recordingsMovement.append(recordingMovement)
	Global.recordingsReaction.append(recordingReaction)
	Global.recordingsFails.append(recordingFails)
	Global.chatLog.append(recordingChat)

func _physics_process(delta: float) -> void:
	if Global.inputHandler == null: return
	if recordInputs:
		var input = Global.inputHandler.getInput()
		timeSinceLastInput += delta
		timeSinceLastReaction += delta
		timeSinceLastFail += delta
		timeSinceLastMessage+=delta
		if(input[1]):
			recordingMovement.append([input[0], timeSinceLastInput])
			timeSinceLastInput = 0
			streamer.move(input[0])
	pass

func appendRecordedReaction(reaction):
	recordingReaction.append([timeSinceLastReaction,reaction])
	timeSinceLastReaction = 0

func appendChatMessage(message):
	recordingChat.append([timeSinceLastMessage,message])
	timeSinceLastMessage=0
	
func _on_eol_stop_playing_music_timer_timeout() -> void:
	pass # Replace with function body.
