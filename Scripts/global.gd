extends Node

# Any stuff that needs to be accessible from anywhere and/or persistent
# between scene changes goes in here

# Random seed, constant within a game.
# Derive from this via rand_from_seed() for things that should be random but consistent
@onready var mainSeed = randi()
const SAVEFILE_NAME = "deadInternetTheory.save"

var inputHandler : InputHandler
var inputRecorder : InputRecorder
var recordingsMovement = []
var recordingsReaction = []
var recordingsFails = []
var currentTrackHandler : TrackPlaybackHandler
var currentStreamIndex = 0
var score = 10
var currentHighScore=0#we want to display the highest score at game over
var highScore=0
var streamerIndices =[]
var currentStreamer=null
var difficulty = 1 # 1: arrow on every note, 4: arrow on every 4th note, etc
var developerMode = false
var musicTracks=[]
var packetsToBeDropped=[]
var videoTitle = [[],[],[]]
signal tact
signal tactArrows

@export var snippetLength=2.4

func _enter_tree():
	loadGame()
	
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
	
func makeSaveDict():
	var saveDict = {
		"highScore" : highScore,
	}
	return saveDict
	
func saveGame():
	var file = FileAccess.open_encrypted_with_pass(SAVEFILE_NAME, FileAccess.WRITE, "superorganism")
	file.store_string(JSON.stringify(makeSaveDict()))
	file.close()

#param(dict): the JSON dictionary object returned parsed from saveFile
#param(value): the Global variable that should be set to the data from the savefile
#param(data): the data name to be fetched from the json dict
func loadDataFromDictSafe(dict, value, data : String):
	var temp = dict.get(data)
	if(temp != null):
		return temp
	else:
		printerr("[Global.loadDataFromDictSafe] dict.get("+data+") returned null")
		return value
		
func loadGame():
	if FileAccess.file_exists(SAVEFILE_NAME):
		var file = FileAccess.open_encrypted_with_pass(SAVEFILE_NAME, FileAccess.READ, "superorganism")
		var dict = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(dict) == TYPE_DICTIONARY:
			highScore = loadDataFromDictSafe(dict, highScore, "highScore")
		else:
			printerr("Corrupted data!")
	else:
		saveGame();
		printerr("No saved data!")
		
func resetSaveFile():
	highScore=0
	saveGame()
