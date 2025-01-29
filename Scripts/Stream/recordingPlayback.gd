extends Node

@export var index = 0
var streamer 
var playing = true
var paused = false
var timeSinceLastInput = 0.0
var timeSinceLastReaction = 0.0
var timeSinceLastFail = 0.0
var timeSinceLastMessage = 0.0
var timeSinceLastDonationReaction=0.0
var timeSinceLastEvent = 0.0
var eventTime = 0.0
var inputIndex = 0
var reactionIndex = 0
var failIndex = 0
var messageIndex=0
var donationReactionIndex=0
var eventIndex = 0
var currentEvent : Event

func setStreamer(newStreamer):
	streamer=newStreamer

func setIndex(i : int):
	index = i
	$TrackPlaybackHandler.setIndex(i)
	if index <= Global.currentStreamIndex - Global.chatDepth:
		$ChatRecorded.off = true

func _ready() -> void:
	Global.pause.connect(pause)
	Global.resume.connect(resume)

func _physics_process(delta: float) -> void:
	checkIndices()

	if playing and !paused:
		timeSinceLastInput += delta
		timeSinceLastReaction += delta
		timeSinceLastFail += delta
		timeSinceLastMessage+=delta
		timeSinceLastEvent += delta
		timeSinceLastDonationReaction+=delta
		if donationReactionIndex < Global.recordDonationReaction[index].size() and Global.recordDonationReaction[index][donationReactionIndex][0]<=timeSinceLastDonationReaction:
			var donationReaction = Global.recordDonationReaction[index][donationReactionIndex][1]
			streamer.donationReaction(donationReaction,false)
			timeSinceLastDonationReaction=0
			donationReactionIndex+=1
		if inputIndex < Global.recordingsMovement[index].size() and Global.recordingsMovement[index][inputIndex][1] <= timeSinceLastInput:
			var input = Global.recordingsMovement[index][inputIndex][0]
			streamer.move(input)
			timeSinceLastInput = 0
			inputIndex += 1
		while reactionIndex < Global.recordingsReaction[index].size() and Global.recordingsReaction[index][reactionIndex] is int:
			reactionIndex += 1
		if reactionIndex < Global.recordingsReaction[index].size() and Global.recordingsReaction[index][reactionIndex][0] <= timeSinceLastReaction:
			var reaction = Global.recordingsReaction[index][reactionIndex][1]
			if reaction != RT.Emotion.NONE:
				streamer.react(reaction)
			timeSinceLastReaction = 0
			reactionIndex += 1
		if !$ChatRecorded.off:
			var chatIndex=index%Global.chatDepth
			if messageIndex<Global.chatLog[chatIndex].size() and  Global.chatLog[chatIndex][messageIndex][0] <= timeSinceLastMessage:
				var message=Global.chatLog[chatIndex][messageIndex][1]
				#$Chat/ChatBackground/RichTextLabel.text=$Chat/ChatBackground/RichTextLabel.text+message
				$ChatRecorded.appendAndTruncate(message)
				timeSinceLastMessage = 0
				messageIndex += 1
		if failIndex < Global.recordingsFails[index].size() and Global.recordingsFails[index][failIndex][0] <= timeSinceLastFail:
			var fail = Global.recordingsFails[index][failIndex]
			$TrackPlaybackHandler.failReaction(fail[1])
			timeSinceLastFail = -fail[1]
			failIndex += 1
		if eventIndex < Global.recordingsEvents[index].size() and Global.recordingsEvents[index][eventIndex][0] <= timeSinceLastEvent:
			currentEvent = Global.recordingsEvents[index][eventIndex][1]
			streamer.event()
			Global.pauseStream(currentEvent.startLayer)
			eventIndex += 1
		if currentEvent != null:
			eventTime += delta
			if eventTime > (currentEvent.length * Global.snippetLength + 1):
				Global.resumeStream()
				currentEvent = null
	pass

func checkIndices():
	if !playing or paused:
		return
	var shouldStop = Global.recordingsMovement.size() <= index
	if !shouldStop:
		var anyListUnfinished = false
		anyListUnfinished = anyListUnfinished || inputIndex < Global.recordingsMovement[index].size()
		anyListUnfinished = anyListUnfinished || reactionIndex < Global.recordingsReaction[index].size()
		anyListUnfinished = anyListUnfinished || failIndex < Global.recordingsFails[index].size()
		shouldStop = !anyListUnfinished
	playing = playing && !shouldStop

func pause(depth : int):
	if depth > index:
		paused = true

func resume(depth : int):
	if depth > index:
		paused = false
