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
var developerMode = false
var performanceMode = false
var musicTracks=[]
var packetToBeDropped=[]
var videoTitle = [[],[],[]]
var chatLog=[]
var chatUsers=[]
var decreaseWrongInput=1.1
var donationOnScreen=false#wasd inputs are not marked as wrong input if this is set to true

var moneyManager : MoneyManager
var moneyEarned = 0
var currentMoneyHighScore = 0
var moneyHighScore = 0
var displayedMoney="0"
var moneyLoss = 2
var overallScore = 0
var overallScoreHighScore=0
var increaseInMoney=100
var nextDonationViewerCount=500
var difficultyDonations=3#how many donation inputs appear
var donationIncrease=500

var health = 1.0 #TODO: reset per game
var healthLossPerFail = 0.1
var healthLoss0Viewers = 0.2
var regenPer100Money = 0.2
var regenSpeed = 100

var musicSnippetIndex = 0
var arrowSnippetIndex = 0
var events = []
var eventIndexArrows = 0
var eventIndexMusic = 0
var eventEnds = []
var pauseDepths = [] # stack of stream IDs. a pause event puts that stream's ID on top, resume takes it off again
var fastPromptMult = 2
var fakePromptsCountdown = -1
var debugWindow : DebugWindow
@onready var arrowTravelDelay = $ArrowTravelDelay

signal tact(int)
signal tactArrows(int) # says whether the arrows should be fast
signal eventImminent(Event)
signal pastEvent(Event)
signal tactFakeArrows
signal pause(int) # supplies the index of the stream that paused
signal resume(int)
signal updateStreamerStats

@export var lengthOfMusic = 5 #number of reaction packets to play
@export var playbackSpeed = 0.575
@export var snippetLength = 2.4

func _enter_tree():
	loadGame()

func prepareGame(resetSeed = true):
	decreaseWrongInput=1.1
	score=10
	nextDonationViewerCount=500
	currentHighScoreViewers=0
	if resetSeed: mainSeed=randi()
	currentStreamIndex=0
	increaseInMoney=100
	moneyEarned=0
	health = 1.0
	recordingsMovement = []
	recordingsReaction = []
	recordingsFails = []
	recordDonationReaction = []
	recordingsEvents = []
	videoTitle = [[],[],[]]
	streamerIndices = []
	musicTracks = []
	packetToBeDropped = []
	events = []
	chatLog = []
	chatUsers = []
	VideoCustomizer.generateFirstTitle()
	startSurvivedTime()
	
func increaseScore(deltaScore):
	score+=deltaScore
	if score>currentHighScoreViewers:
		currentHighScoreViewers=score

func decreaseHealth():
	health -= healthLossPerFail
	updateStreamerStats.emit()
	checkHealthGameOver()

func checkHealthGameOver():
	if health <= 0:
		gameOver()

func _ready():
	$Metronome.wait_time = snippetLength
	$MetronomeArrows.wait_time = snippetLength
	$UpcomingEvent.wait_time = snippetLength - 1.2

func resetPerStream():
	musicSnippetIndex = 0
	arrowSnippetIndex = 0
	eventIndexArrows = 0
	eventIndexMusic = 0
	events = []

func _on_metronome_timeout() -> void:
	if eventEnds.size() > 0 and eventEnds.back() <= 0:
		eventEnds.pop_back()
		resumeStream()
	tact.emit(musicSnippetIndex)
	musicSnippetIndex += 1
	if eventEnds.size() > 0:
		eventEnds[eventEnds.size()-1] -= 1
	
	var endsString = ""
	for entry in eventEnds:
		endsString += str(entry) + ","
	debugWindow.setEntry("Events", endsString)
	debugWindow.setEntry("MusicIndex", str(musicSnippetIndex)+"/"+str(musicTracks.back().size()))

func startMetronome():
	$Metronome.start()
	tact.emit(musicSnippetIndex)
	musicSnippetIndex += 1
	debugWindow.setEntry("MusicIndex", str(musicSnippetIndex)+"/"+str(musicTracks.back().size()))
	
func stopMetronome():
	$Metronome.stop()

func checkEventPrep():
	if eventIndexArrows < events.size():
		var event = events[eventIndexArrows]
		if event.startIndex == arrowSnippetIndex + 2 and event.startLayer == currentStreamIndex:
			$UpcomingEvent.start()
			fakePromptsCountdown = 0
			#arrowSnippetIndex -= 1
		#eventIndexArrows += 1
	debugWindow.setEntry("InEvent", getPromptSpeedState())

func _on_metronome_arrows_timeout() -> void:
	if fakePromptsCountdown == 0:
		$FakeArrowDelay.start()
	fakePromptsCountdown -= 1
	checkEventPrep()
	tactArrows.emit(arrowSnippetIndex)
	arrowSnippetIndex += 1
	
	debugWindow.setEntry("ArrowIndex", str(arrowSnippetIndex)+"/"+str(musicTracks.back().size()))
	
func startMetronomeArrows():
	$MetronomeArrows.start()
	$ArrowTravelDelay.start()
	checkEventPrep()
	tactArrows.emit(arrowSnippetIndex)
	arrowSnippetIndex += 1
	debugWindow.setEntry("ArrowIndex", str(arrowSnippetIndex)+"/"+str(musicTracks.back().size()))
	
func stopMetronomeArrows():
	$MetronomeArrows.stop()

func currentStreamPaused():
	return pauseDepths.size() > 0 and pauseDepths.back() == currentStreamIndex

func getPromptSpeedState(): # Returns whether prompts should be fast right now
	if eventIndexArrows < events.size():
		var event = events[eventIndexArrows]
		return event.startIndex <= arrowSnippetIndex and event.startIndex + event.length > arrowSnippetIndex
	return false

func initPause():
	var event = events[eventIndexMusic]
	if event.startIndex == arrowSnippetIndex:
		if event.startLayer != currentStreamIndex:
			pastEvent.emit(event)
		else:
			musicSnippetIndex -= 1
	eventEnds.push_back(event.length)
	#print("Event started, ends in: " + str(event.length))
	pauseStream(currentStreamIndex)

func pauseStream(depth : int):
	pauseDepths.push_back(depth)
	pause.emit(depth)
	#print("Paused. Pause Stack:")
	#for i in pauseDepths:
		#print("- " + str(i))

func resumeStream():
	var depth = pauseDepths.pop_back()
	resume.emit(depth)
	#print("Resumed. Pause Stack:")
	#for i in pauseDepths:
		#print("- " + str(i))

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
		"overallScoreHighScore" : overallScoreHighScore
	}
	return saveDict

func startSurvivedTime():
	survivedTime=Time.get_unix_time_from_system()

func gameOver():
	if !developerMode or Input.is_action_pressed("ui_end"): 
		get_tree().call_deferred("change_scene_to_file","res://Scenes/gameOver.tscn")
		survivedTime=Time.get_unix_time_from_system() - survivedTime
		$ArrowTravelDelay.stop()
		$UpcomingEvent.stop()
		$FakeArrowDelay.stop()
		stopMetronome()
		stopMetronomeArrows()
	
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


func _on_arrow_travel_delay_timeout() -> void:
	startMetronome()

func _on_upcoming_event_timeout() -> void:
	eventImminent.emit(events[eventIndexArrows])

func _on_fake_arrow_delay_timeout() -> void:
	tactFakeArrows.emit()
