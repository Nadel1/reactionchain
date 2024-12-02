extends Node

@export var index = 0
var streamer 
var playing = true
var timeSinceLastInput = 0.0
var timeSinceLastReaction = 0.0
var timeSinceLastFail = 0.0
var inputIndex = 0
var reactionIndex = 0
var failIndex = 0

func setStreamer(newStreamer):
	streamer=newStreamer

func setIndex(i : int):
	index = i
	$TrackPlaybackHandler.setIndex(i)

func _physics_process(delta: float) -> void:
	checkIndices()
	if playing:
		timeSinceLastInput += delta
		timeSinceLastReaction += delta
		timeSinceLastFail += delta
		if inputIndex < Global.recordingsMovement[index].size() and Global.recordingsMovement[index][inputIndex][1] <= timeSinceLastInput:
			var input = Global.recordingsMovement[index][inputIndex][0]
			streamer.move(input)
			timeSinceLastInput = 0
			inputIndex += 1
		if reactionIndex < Global.recordingsReaction[index].size() and Global.recordingsReaction[index][reactionIndex][0] <= timeSinceLastReaction:
			var reaction = Global.recordingsReaction[index][reactionIndex][1]
			if reaction != RT.Emotion.NONE:
				streamer.react(reaction)
			timeSinceLastReaction = 0
			reactionIndex += 1
		if failIndex < Global.recordingsFails[index].size() and Global.recordingsFails[index][failIndex][0] <= timeSinceLastFail:
			var fail = Global.recordingsFails[index][failIndex]
			$TrackPlaybackHandler.failReaction(fail[1])
			timeSinceLastFail = -fail[1]
			failIndex += 1
			
	pass

func checkIndices():
	if !playing:
		return
	var shouldStop = Global.recordingsMovement.size() <= index
	if !shouldStop:
		var anyListUnfinished = false
		anyListUnfinished = anyListUnfinished || inputIndex < Global.recordingsMovement[index].size()
		anyListUnfinished = anyListUnfinished || reactionIndex < Global.recordingsReaction[index].size()
		anyListUnfinished = anyListUnfinished || failIndex < Global.recordingsFails[index].size()
		shouldStop = !anyListUnfinished
	playing = playing && !shouldStop
