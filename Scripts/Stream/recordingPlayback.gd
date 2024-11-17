extends Node

@export var index = 0
var streamer 
var playing = true
var timeSinceLastInput = 0.0
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
		if Global.recordings.size() <= index || Global.recordings[index].size() <= inputIndex:
			playing = false
			print("End playback")
			return
		timeSinceLastInput += delta
		if Global.recordings[index][inputIndex][1] == timeSinceLastInput:
			var input = Global.recordings[index][inputIndex][0]
			streamer.move(input)
			if reactionIndex<Global.reactions.size() and Global.reactions[reactionIndex].inputIndex==inputIndex:
				streamer.react(Global.reactions[reactionIndex].reaction)
				reactionIndex+=1
			timeSinceLastInput = 0
			inputIndex += 1
	pass
