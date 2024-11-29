extends Node

# Any stuff that needs to be accessible from anywhere and/or persistent
# between scene changes goes in here

@onready var videoSeed = randi()

var inputHandler : InputHandler
var inputRecorder : InputRecorder
var recordingsMovement = []
var recordingsReaction = []
var recordingsFails = []
var currentTrackHandler : TrackPlaybackHandler
var currentStreamIndex = 0
var score = 10
var streamerIndices =[]
var currentStreamer=null
var difficulty = 1 # 1: arrow on every note, 4: arrow on every 4th note, etc
var developerMode = false #TODO: When true disables being able to fail
var musicTracks=[]
var packetsToBeDropped=[]
signal tact
signal tactArrows

@export var snippetLength=2.4

func _ready():
	$Metronome.wait_time=snippetLength
	$MetronomeArrows.wait_time=snippetLength
	

func _on_metronome_timeout() -> void:
	self.emit_signal("tact")

func startMetronome():
	$Metronome.start()
	self.emit_signal("tact")
	
func stopMetronome():
	$Metronome.stop()


func _on_metronome_arrows_timeout() -> void:
	self.emit_signal("tactArrows")
	
func startMetronomeArrows():
	$MetronomeArrows.start()
	self.emit_signal("tactArrows")
	
func stopMetronomeArrows():
	$MetronomeArrows.stop()
