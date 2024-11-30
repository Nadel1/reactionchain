extends Node2D

const BUTTONRIGHT=preload("res://Scenes/Objects/Buttons/ButtonRight.tscn")
const BUTTONLEFT=preload("res://Scenes/Objects/Buttons/ButtonLeft.tscn")
const BUTTONUP=preload("res://Scenes/Objects/Buttons/ButtonUp.tscn")
const BUTTONDOWN=preload("res://Scenes/Objects/Buttons/ButtonDown.tscn")
const MARKER=preload("res://Scenes/Objects/reactionPacketMarker.tscn")
const SPLAT=preload("res://Scenes/Objects/FX/splat.tscn")

@onready var animatedSprite=$HitZoneAnimatedSprite2D
@onready var spawnPoint=$SpawnPoint
@onready var judgingUI=$UI/JudgingPrompt
@onready var inputRecorder=get_parent().get_parent().find_child("InputRecorder")

@export var scoreChangeGoodHit=10
@export var scoreChangeOkayHit=5
@export var scoreChangeBadHit=-5

var buttonPrompts=[BUTTONRIGHT,BUTTONLEFT,BUTTONUP,BUTTONDOWN]
var numberOfButtonPrompts=4
var buttonSequence=[]#keep track of current buttons spawned, so that they can be removed in case of too early button press
var goodHit=false
var judgingPromptsGood=["YEY","YIPPIE","WAHOO"]
var judgingPromptsOkay=["okay"]
var judgingPromptsBad=["uff","bad"]
var arrowSpawnID = 0
var currentButtonToEvaluate

#abstraction for reactions
var correctReactionPacket=true
var countReactionPacket=0
var reactionIndex=0#when going through previous reactions
var reactionArray=[]
var currentPacketDuration=0.0
var firstPacketStarted=false
var countMarker=0#keep track if current marker is start or end marker
var lastButtonSpawned
	
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
		else:
			evaluateScore(null,false)

func _process(delta: float) -> void:
	if firstPacketStarted:
		currentPacketDuration += delta

func spawnButton():
	if arrowSpawnID % Global.difficulty == 0:
		var spawnIndex=randi()%numberOfButtonPrompts
		var newButtonPrompt=buttonPrompts[spawnIndex].instantiate()
		newButtonPrompt.global_position=spawnPoint.global_position
		get_parent().call_deferred("add_child",newButtonPrompt)
		buttonSequence.append(newButtonPrompt)
		return newButtonPrompt
	arrowSpawnID += 1
	

func spawnMarker():
	var newMarker=MARKER.instantiate()
	newMarker.global_position=spawnPoint.global_position
	get_parent().call_deferred("add_child",newMarker)
	if lastButtonSpawned!=null:
		lastButtonSpawned.lastButton=true

func _on_midi_player_arrows_midi_event(_channel: Variant, event: Variant) -> void:
	if event.type==144:
		if event.velocity==1:
			spawnMarker()
		elif event.velocity==2:
			spawnMarker()
		elif event.velocity==127:
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
				var lastReaction=Global.recordingsReaction[Global.currentStreamIndex-1][countReactionPacket-1][1]
				if lastReaction==RT.dirToInt(RT.Emotion.NONE):
					reaction=RT.intToDir(randi()%4)#randomly select one of the four emotions if first streamer or no reactions to pull from
				else:
					reaction=lastReaction
		else:
			reaction=RT.dirToInt(RT.Emotion.NONE)#the none reaction
			inputRecorder.reactionFailed(currentPacketDuration)
			currentPacketDuration = 0.0
		Global.currentStreamer.react(reaction)
		inputRecorder.appendRecordedReaction(reaction)
		currentButtonToEvaluate=null
		correctReactionPacket = true
			
func evaluateScore(buttonPrompt,correctInput=true):
	var splat = SPLAT.instantiate()
	get_parent().add_child(splat)
	splat.global_position = $UI/SplatSpawnPos.global_position
	if goodHit&&correctInput&&buttonPrompt!=null:#correct input in hitzone
		if buttonPrompt.goodHit:
			Global.score+=scoreChangeGoodHit
			#judgingUI.text="[center]"+judgingPromptsGood.pick_random()+"[/center]"
			splat.call_deferred("setText", 2)
		else: 
			Global.score+=scoreChangeOkayHit
			#judgingUI.text="[center]"+judgingPromptsOkay.pick_random()+"[/center]"
			splat.call_deferred("setText", 1)
		playScoreIncrease()
		buttonSequence.pop_front().queue_free()
		
	else:#either incorrect input, no input at all (too late), or way too early
		correctReactionPacket=false
		playScoreDecrease()
		Global.score+=scoreChangeBadHit
		#judgingUI.text="[center]"+judgingPromptsBad.pick_random()+"[/center]"
		splat.call_deferred("setText", 0)
	if buttonPrompt!=null and buttonPrompt.lastButton==true:
		react(correctReactionPacket)
	

func registerInput(inputString):
	if buttonSequence.is_empty()==true:
		evaluateScore(null,false)#substract points when input for example at end of level
	if currentButtonToEvaluate!=null:
		if currentButtonToEvaluate.getInput()==inputString:
			evaluateScore(currentButtonToEvaluate,true)
	else: 
		evaluateScore(null,false)
		
func dealWithMarker():
	firstPacketStarted = true
	countMarker+=1
	if countMarker%2==1:
		#startmarker
		countReactionPacket += 1
		currentPacketDuration = 0.0
		
func _on_good_area_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("PacketMarker"):
		dealWithMarker()
	else:
		goodHit=true
		if buttonSequence.front()!=null:
			currentButtonToEvaluate=buttonSequence.front()
			currentButtonToEvaluate.hitZoneEnter(true)
	
func _on_good_area_area_exited(area: Area2D) -> void:
	if !area.get_parent().is_in_group("PacketMarker"):
		goodHit=false
		
func _on_late_area_area_entered(area: Area2D) -> void:
	if !area.get_parent().is_in_group("PacketMarker"):
		evaluateScore(currentButtonToEvaluate,false)
		buttonSequence.pop_front().queue_free()
