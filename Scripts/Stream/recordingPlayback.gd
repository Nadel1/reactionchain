extends Node

@export var index = 0
var streamer 
var playing = true
var timeSinceLastInput = 0.0
var timeSinceLastReaction=0.0
var inputIndex = 0
var reactionIndex=0

func setStreamer(newStreamer):
	streamer=newStreamer

func setIndex(i : int):
	index = i
	$TrackPlaybackHandler.setIndex(i)
	
func start():
	$TrackPlaybackHandler.start()

func _physics_process(delta: float) -> void:
	if playing:
<<<<<<< HEAD
		if Global.recordingsMovement.size() <= index || Global.recordingsMovement[index].size() <= inputIndex:
=======
		if Global.inputRecordings.size() <= index || Global.inputRecordings[index].size() <= inputIndex:
>>>>>>> b3011b9 (Add unified TrackPlaybackHandler)
			playing = false
			print("End playback")
			return
		timeSinceLastInput += delta
<<<<<<< HEAD
		timeSinceLastReaction+=delta
		if Global.recordingsMovement[index][inputIndex][1] == timeSinceLastInput:
			var input = Global.recordingsMovement[index][inputIndex][0]
=======
		if Global.inputRecordings[index][inputIndex][1] == timeSinceLastInput:
			var input = Global.inputRecordings[index][inputIndex][0]
>>>>>>> b3011b9 (Add unified TrackPlaybackHandler)
			streamer.move(input)
			timeSinceLastInput = 0
			inputIndex += 1
		if reactionIndex < Global.recordingsReaction[index].size()and Global.recordingsReaction[index][reactionIndex][0]==timeSinceLastReaction:
			streamer.react( Global.recordingsReaction[index][reactionIndex][1])
			timeSinceLastReaction=0
			reactionIndex+=1
			
	pass
