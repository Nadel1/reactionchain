extends Node
class_name InputRecorder

var recordingMovement = []
var recordingReaction = []
var recordingFails = []
var recordingChat = []
var recordingEvents = []
var recordDonationReaction=[]
var timeSinceLastInput = 0.0
var timeSinceLastReaction = 0.0
var timeSinceLastFail = 0.0
var timeSinceLastMessage=0.0
var timeSinceLastEvent = 0.0
var timeSinceLastDonationReaction = 0.0

var recordInputs = true
var recordChat = true
var streamer

func setStreamer(newStreamer):
	streamer=newStreamer

func _ready() -> void:
	Global.inputRecorder = self

func setPotato():
	recordChat = false

func reactionFailed(packetDuration: float):
	recordingFails.append([timeSinceLastFail-packetDuration, packetDuration])
	timeSinceLastFail = 0.0

func stopRecording():
	recordInputs = false
	Global.recordingsMovement.append(recordingMovement)
	Global.recordingsReaction.append(recordingReaction)
	Global.recordingsFails.append(recordingFails)
	Global.recordDonationReaction.append(recordDonationReaction)
	if Global.chatLog.size()<Global.chatDepth:
		Global.chatLog.append(recordingChat)
	else:
		Global.chatLog[Global.currentStreamIndex%Global.chatDepth]=recordingChat
	Global.recordingsEvents.append(recordingEvents)

func _physics_process(delta: float) -> void:
	if Global.inputHandler == null: return
	if recordInputs:
		var input = Global.inputHandler.getInput()
		timeSinceLastInput += delta
		timeSinceLastReaction += delta
		timeSinceLastFail += delta
		timeSinceLastMessage+=delta
		timeSinceLastDonationReaction+=delta
		timeSinceLastEvent += delta
		if(input[1]):
			recordingMovement.append([input[0], timeSinceLastInput])
			timeSinceLastInput = 0
			streamer.move(input[0])
	pass

func appendDonationReaction(positive:bool):
	recordDonationReaction.append([timeSinceLastDonationReaction,positive])
	timeSinceLastDonationReaction=0
	
func appendRecordedReaction(reaction):
	recordingReaction.append([timeSinceLastReaction,reaction])
	timeSinceLastReaction = 0

func appendChatMessage(message):
	if recordChat:
		recordingChat.append([timeSinceLastMessage,message])
		timeSinceLastMessage = 0

func appendEvent(event):
	recordingEvents.append([timeSinceLastEvent,event])
	timeSinceLastEvent = 0
