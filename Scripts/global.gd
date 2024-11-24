extends Node

# Any stuff that needs to be accessible from anywhere and/or persistent
# between scene changes goes in here


var inputHandler : InputHandler
var inputRecorder : InputRecorder
var recordingsMovement = []
var recordingsReaction = []
var recordingsFails = []
var currentTrackHandler : TrackPlaybackHandler
var currentStreamIndex = 0
var score = 0
var streamerIndices =[]
var currentStreamer=null
var difficulty = 1 # 1: arrow on every note, 4: arrow on every 4th note, etc
var musicTracks=[]
var packetsToBeDropped=[]
signal tact

func _on_metronome_timeout() -> void:
	self.emit_signal("tact")

func startMetronome():
	$Metronome.start()
	self.emit_signal("tact")
	
func stopMetronome():
	$Metronome.stop()
