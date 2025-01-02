extends Node2D

const BUTTONRIGHT=preload("res://Scenes/Objects/Buttons/ButtonRight.tscn")
const BUTTONLEFT=preload("res://Scenes/Objects/Buttons/ButtonLeft.tscn")
const BUTTONUP=preload("res://Scenes/Objects/Buttons/ButtonUp.tscn")
const BUTTONDOWN=preload("res://Scenes/Objects/Buttons/ButtonDown.tscn")
const MARKER=preload("res://Scenes/Objects/Buttons/reactionPacketMarker.tscn")
const EVENTTRIGGER=preload("res://Scenes/Objects/Buttons/EventTrigger.tscn")
const SPLAT=preload("res://Scenes/Objects/FX/splat.tscn")
enum Score{GOOD, OKAY, BAD}

@onready var animatedSprite=$HitZoneAnimatedSprite2D
@onready var spawnPoint=$SpawnPoint
@onready var fastSpawnPoint = $FastSpawnPoint
@onready var inputRecorder=get_parent().get_parent().find_child("InputRecorder")
@onready var chat=get_parent().find_child("Chat")

@export var thresholdFastIncrease=1000
@export var thresholdUpperFastIncrease=10000
@export var increaseGoodHit=0.0125
@export var increaseOkayHit=0.00625
@export var changePerfectHitHighViewercount=2
@export var changeOkHitHighViewercount=1
@export var scoreOffset=10
@export var removeScore=0.25
@export var decreaseWrongInput=1.125
@export var increaseOfLossPerWrongInput=0.1
@export var startValueDecrease=5


var buttonPrompts=[BUTTONRIGHT,BUTTONLEFT,BUTTONUP,BUTTONDOWN]
var numberOfButtonPrompts=4
var arrowSpawnID = 0

#abstraction for reactions
var correctReactionPacket=true
var countReactionPacket=0
var reactionIndex=0#when going through previous reactions
var reactionArray=[]
var currentPacketDuration=0.0
var firstPacketStarted=false

var countMarker=0#keep track if current marker is start or end marker
var lastButtonSpawned
var inPacket = false

var debuglastButton=0

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("right"):
			registerInput("right")
		elif event.is_action_pressed("left"):
			registerInput("left")
		elif event.is_action_pressed("up"):
			registerInput("up")
		elif event.is_action_pressed("down"):
			registerInput("down")

func _ready() -> void:
	Global.eventImminent.connect(spawnEventTrigger)
	fastSpawnPoint.global_position = animatedSprite.global_position + (spawnPoint.global_position - animatedSprite.global_position) * Global.fastPromptMult

func _process(delta: float) -> void:
	if firstPacketStarted:
		currentPacketDuration += delta

func spawnButton():
	var fast = Global.getPromptSpeedState()
	if arrowSpawnID % Global.difficulty == 0:
		var spawnIndex=randi()%numberOfButtonPrompts
		var newButtonPrompt=buttonPrompts[spawnIndex].instantiate()
		newButtonPrompt.global_position=fastSpawnPoint.global_position if fast else spawnPoint.global_position
		newButtonPrompt.setFast(fast)
		get_parent().call_deferred("add_child",newButtonPrompt)
		return newButtonPrompt
	arrowSpawnID += 1
	
func calculateScoreChange(score:Score):
	var change=0
	var x=Global.score
	match score:
		Score.GOOD:
			if x<thresholdFastIncrease:
				change=increaseGoodHit*x+scoreOffset
			elif thresholdFastIncrease<=x and x< thresholdUpperFastIncrease:
				change=increaseGoodHit*2*x+scoreOffset
			else: 
				change=changePerfectHitHighViewercount
		Score.OKAY:
			if x<thresholdFastIncrease:
				change=increaseOkayHit*x+scoreOffset
			elif thresholdFastIncrease<=x and x< thresholdUpperFastIncrease:
				change=increaseOkayHit*2*x+scoreOffset
			else:
				x= changeOkHitHighViewercount
		Score.BAD:
			Global.decreaseWrongInput+=increaseOfLossPerWrongInput
			change=startValueDecrease+x*removeScore*Global.decreaseWrongInput 
	return int(change)

	
func spawnMarker(end : bool):
	var fast = Global.getPromptSpeedState()
	if inPacket and !end:
		spawnMarker(true)
	inPacket = !end
	var newMarker=MARKER.instantiate()
	newMarker.global_position=fastSpawnPoint.global_position if fast else spawnPoint.global_position
	newMarker.setFast(fast)
	get_parent().call_deferred("add_child",newMarker)
	newMarker.setVisible(Global.developerMode)
	if !end:
		newMarker.setIndex(Global.arrowSnippetIndex)
	newMarker.setStart(!end)
	if end and lastButtonSpawned!=null:
		#print("last button detected ",debuglastButton)
		debuglastButton+=1
		lastButtonSpawned.lastButton=true

func spawnEventTrigger(event):
	var trigger = EVENTTRIGGER.instantiate()
	trigger.encodedEvent = event
	trigger.global_position=spawnPoint.global_position
	trigger.find_child("Label").text = str(Global.events[Global.eventIndexArrows-1].length)
	get_parent().call_deferred("add_child",trigger)

func _on_midi_player_arrows_midi_event(_channel: Variant, event: Variant) -> void:
	if event.type==144:
		if event.velocity==1:
			spawnMarker(false)
		elif event.velocity==2:
			spawnMarker(true)
		else:
			lastButtonSpawned=spawnButton()
	

func playScoreDecrease():#animate hitzone and maybe later add more music here? 
	animatedSprite.play("wrongHit")
	Global.currentTrackHandler.failInput()

func playScoreIncrease():
	animatedSprite.play("hit")
	
	
func react(correctReaction=true):
	var reaction
	if Global.currentStreamer!=null:
		if correctReaction:
			#on first layer, always random reaction
			if Global.currentStreamIndex==0 :
				reaction=RT.intToDir(randi()%4)#randomly select one of the four emotions if first streamer or no reactions to pull from
			else:
				#use last reaction, or if the last reaction was none, replace it with random
				var lastReaction = Global.recordingsReaction[Global.currentStreamIndex-1][countReactionPacket-1]
				if lastReaction is int or lastReaction[1]==RT.dirToInt(RT.Emotion.NONE):
					reaction=RT.intToDir(randi()%4)#randomly select one of the four emotions if first streamer or no reactions to pull from
				else:
					reaction=lastReaction[1]
			chat.initiateSendReactionMessage(reaction)
		else:
			reaction=RT.dirToInt(RT.Emotion.NONE)#the none reaction
			inputRecorder.reactionFailed(currentPacketDuration)
			currentPacketDuration = 0.0
			Global.packetToBeDropped[min(Global.packetToBeDropped.size()-1,countReactionPacket-1)] = true
		Global.currentStreamer.react(reaction)
		
		inputRecorder.appendRecordedReaction(reaction)
		#currentButtonToEvaluate=null
		correctReactionPacket = true
			
func evaluateScore(buttonPrompt,correctInput=true):
	var splat = SPLAT.instantiate()
	get_parent().add_child(splat)
	splat.global_position = $UI/SplatSpawnPos.global_position
	var scoreChange
	if correctInput&&buttonPrompt!=null:#correct input in hitzone
		if buttonPrompt.goodHit:
			scoreChange=calculateScoreChange(Score.GOOD)
			Global.score+=scoreChange
			Global.increaseScore(scoreChange)
			splat.call_deferred("setText", 2)
		else: 
			scoreChange=calculateScoreChange(Score.OKAY)
			Global.score+=scoreChange
			Global.increaseScore(scoreChange)
			splat.call_deferred("setText", 1)
		playScoreIncrease()
	else:#either incorrect input, no input at all (too late), or way too early
		correctReactionPacket=false
		playScoreDecrease()
		scoreChange=calculateScoreChange(Score.BAD)
		Global.score-=scoreChange
		splat.call_deferred("setText", 0)
	if buttonPrompt!=null and buttonPrompt.lastButton==true:
		react(correctReactionPacket)
	if buttonPrompt!=null:
		buttonPrompt.queue_free()
	if(Global.score<=0):
		gameOver()
	

func gameOver():
	if !Global.developerMode: 
		get_tree().call_deferred("change_scene_to_file","res://Scenes/gameOver.tscn")
		Global.survivedTime=Time.get_unix_time_from_system()-Global.survivedTime
		Global.stopMetronome()
		Global.stopMetronomeArrows()

func compareInput(prompt, inputString):
	return prompt.getInput() == inputString

func isPrompt(area):
	return area.get_parent().is_in_group("InputPrompt")

func registerInput(inputString):
	var areasInRange = $HitZoneAnimatedSprite2D/GoodArea.get_overlapping_areas().filter(isPrompt)
	if areasInRange.size() > 0:
		for area in areasInRange:
			if compareInput(area.get_parent(), inputString):
				evaluateScore(area.get_parent(),true)
				return
	else: 
		evaluateScore(null,false)
		
func dealWithMarker():
	if countMarker%2==1:
		#startmarker
		countReactionPacket += 1
		#print("count increased: ",countReactionPacket)
		currentPacketDuration = 0.0
	countMarker+=1
		

func dealWithEventTrigger(eventTrigger):
	Global.currentStreamer.event()
	Global.inputRecorder.appendEvent(eventTrigger.encodedEvent)

func dealWithEventStart():
	Global.initPause()

func _on_good_area_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("PacketMarker"):
		dealWithMarker()
	elif area.get_parent().is_in_group("EventTrigger"):
		dealWithEventTrigger(area.get_parent())
	elif area.get_parent().is_in_group("EventStart"):
		dealWithEventStart()
	else:
		#goodHit=true
		area.get_parent().hitZoneEnter(true)
	
func _on_good_area_area_exited(area: Area2D) -> void:
	#if !area.get_parent().is_in_group("InputPrompt"):
		#goodHit=false
	pass
		
func _on_late_area_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("InputPrompt"):
		evaluateScore(area.get_parent(),false)
