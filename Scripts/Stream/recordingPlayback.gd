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
	var music = $AudioTrackProvider.getTrack(index)
	var instrument = $AudioTrackProvider.getSoundFont(index)
	if music != null:
		$MidiPlayer.set_file(music)
		$MidiPlayer.set_soundfont(instrument)

func _physics_process(delta: float) -> void:
	if playing:
		if Global.recordingsMovement.size() <= index || Global.recordingsMovement[index].size() <= inputIndex:
			playing = false
			print("End playback")
			return
		timeSinceLastInput += delta
		timeSinceLastReaction+=delta
		if Global.recordingsMovement[index][inputIndex][1] == timeSinceLastInput:
			var input = Global.recordingsMovement[index][inputIndex][0]
			streamer.move(input)
			timeSinceLastInput = 0
			inputIndex += 1
		if reactionIndex < Global.recordingsReaction[index].size()and Global.recordingsReaction[index][reactionIndex][0]==timeSinceLastReaction:
			streamer.react( Global.recordingsReaction[index][reactionIndex][1])
			timeSinceLastReaction=0
			reactionIndex+=1
			
	pass
