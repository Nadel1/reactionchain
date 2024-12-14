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
var recordDonationReaction = []
var recordingsEvents = []
var currentTrackHandler : TrackPlaybackHandler
var currentStreamIndex = 0
var score = 10
var currentHighScoreViewers=0#we want to display the highest score at game over
var survivedTime=0.0
var highScoreViewers=0
var highScoreTime=0.0
var streamerIndices =[]
var currentStreamer=null
var chatDepth=5#at some point you cant read it anymore
var difficulty = 1 # 1: arrow on every note, 4: arrow on every 4th note, etc
var developerMode = true
var musicTracks=[]
var packetToBeDropped=[]
var videoTitle = [[],[],[]]
var chatLog=[]
var chatUsers=[]
var decreaseWrongInput=1.1
var donationOnScreen=false#wasd inputs are not marked as wrong input if this is set to true

var moneyEarned = 0
var moneyHighScore=0
var overallScore = 0
var overallScoreHighScore=0
var increaseInMoney=100
var nextDonationViewerCount=500
var chatUsers=[]
var difficultyDonations=3#how many donation inputs appear
var viewersNeededToNextDonation=500

var musicSnippetIndex = 0
var arrowSnippetIndex = 0
var events = []
var eventIndexArrows = 0
var eventIndexMusic = 0
var eventEnds = []
var pauseDepths = [] # stack of stream IDs. a pause event puts that stream's ID on top, resume takes it off again

signal tact
signal tactArrows
signal eventImminent
signal pastEvent(Event)
signal pause(int)
signal resume(int)

@export var lengthOfMusic = 5 #number of reaction packets to play
@export var playbackSpeed = 0.575
@export var snippetLength = 2.4

func _enter_tree():
	loadGame()
	
func increaseScore(deltaScore):
	score+=deltaScore
	if score>currentHighScoreViewers:
		currentHighScoreViewers=score

func _ready():
	$Metronome.wait_time=snippetLength
	$MetronomeArrows.wait_time=snippetLength
	VideoCustomizer.generateFirstTitle()

func resetPerStream():
	musicSnippetIndex = 0
	arrowSnippetIndex = 0
	eventIndexArrows = 0
	eventIndexMusic = 0

func _on_metronome_timeout() -> void:
	if eventEnds.size() > 0 and eventEnds.back() <= 0:
		eventEnds.pop_back()
		resumeStream()
	if eventIndexMusic < events.size() and events[eventIndexMusic].startIndex == arrowSnippetIndex:
		var event = events[eventIndexMusic]
		if event.startIndex == arrowSnippetIndex:
			if event.startLayer != currentStreamIndex:
				pastEvent.emit(event)
		eventEnds.push_back(event.length + 1)
		print("Event started, ends in: " + str(event.length + 1))
	tact.emit()
	musicSnippetIndex += 1
	if eventEnds.size() > 0:
		eventEnds[eventEnds.size()-1] -= 1

func startMetronome():
	$Metronome.start()
	tact.emit()
	#musicSnippetIndex += 1
	
func stopMetronome():
	$Metronome.stop()


func _on_metronome_arrows_timeout() -> void:
	if eventIndexArrows < events.size() and events[eventIndexArrows].startIndex == arrowSnippetIndex:
		var event = events[eventIndexArrows]
		if event.startIndex == arrowSnippetIndex and event.startLayer == currentStreamIndex:
			eventImminent.emit()
		eventIndexArrows += 1
	tactArrows.emit()
	arrowSnippetIndex += 1
	
func startMetronomeArrows():
	$MetronomeArrows.start()
	tactArrows.emit()
	#arrowSnippetIndex += 1
	
func stopMetronomeArrows():
	$MetronomeArrows.stop()

func pauseStream(depth : int):
	pauseDepths.push_back(depth)
	pause.emit(depth)
	print("Paused. Pause Stack:")
	for i in pauseDepths:
		print("- " + str(i))

func resumeStream():
	var depth = pauseDepths.pop_back()
	resume.emit(depth)
	print("Resumed. Pause Stack:")
	for i in pauseDepths:
		print("- " + str(i))

func insertEvent(newEvent : Event):
	if events.size() == 0 or events.back().startIndex <= newEvent.startIndex:
		events.append(newEvent)
		return
	
	var readjustingIndices = false
	for i in events.size():
		var oldEvent = events[i]
		if !readjustingIndices:
			if oldEvent.startIndex >= newEvent.startIndex:
				readjustingIndices = true
				events.insert(i, newEvent)
				oldEvent.startIndex += newEvent.length
		else:
			oldEvent.startIndex += newEvent.length

func makeSaveDict():
	var saveDict = {
		"highScoreViewers" : highScoreViewers,
		"highScoreTime" : highScoreTime,
		"moneyHighScore" : moneyHighScore,
		"overallScoreHighScore" : overallScoreHighScore
	}
	return saveDict

func startSurvivedTime():
	survivedTime=Time.get_unix_time_from_system()
	
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
			highScoreViewers = loadDataFromDictSafe(dict, highScoreViewers, "highScoreViewers")
			highScoreTime = loadDataFromDictSafe(dict, highScoreTime, "highScoreTime")
			moneyHighScore =loadDataFromDictSafe(dict, moneyHighScore, "moneyHighScore")
			overallScoreHighScore = loadDataFromDictSafe(dict, overallScoreHighScore, "overallScoreHighScore")
		else:
			printerr("Corrupted data!")
	else:
		saveGame();
		printerr("No saved data!")
		
func resetSaveFile():
	highScoreViewers=0
	moneyHighScore=0
	highScoreTime=0
	saveGame()
