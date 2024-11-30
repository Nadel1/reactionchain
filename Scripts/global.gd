extends Node

# Any stuff that needs to be accessible from anywhere and/or persistent
# between scene changes goes in here

# Random seed, constant within a game.
# Derive from this via rand_from_seed() for things that should be random but consistent
@onready var mainSeed = randi()

var inputHandler : InputHandler
var inputRecorder : InputRecorder
var recordingsMovement = []
var recordingsReaction = []
var recordingsFails = []
var currentTrackHandler : TrackPlaybackHandler
var currentStreamIndex = 0
var score = 0
var currentHighScore=0#we want to display the highest score at game over
var streamerIndices =[]
var currentStreamer=null
var difficulty = 1 # 1: arrow on every note, 4: arrow on every 4th note, etc
var developerMode = true #TODO: When true disables being able to fail
var musicTracks=[]
var packetsToBeDropped=[]
var videoTitle = [[],[],[]]
signal tact
signal tactArrows

@export var snippetLength=2.4

func useDevMode():
	developerMode=!developerMode#turn on/off
	
func increaseScore(deltaScore):
	score+=deltaScore
	if score>currentHighScore:
		currentHighScore=score

func _ready():
	$Metronome.wait_time=snippetLength
	$MetronomeArrows.wait_time=snippetLength
	VideoCustomizer.generateFirstTitle()
	

func _on_metronome_timeout() -> void:
	tact.emit()

func startMetronome():
	$Metronome.start()
	tact.emit()
	
func stopMetronome():
	$Metronome.stop()


func _on_metronome_arrows_timeout() -> void:
	tactArrows.emit()
	
func startMetronomeArrows():
	$MetronomeArrows.start()
	tactArrows.emit()
	
func stopMetronomeArrows():
	$MetronomeArrows.stop()
