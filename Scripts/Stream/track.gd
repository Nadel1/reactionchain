extends Node2D

const BUTTONRIGHT=preload("res://Scenes/Objects/Buttons/ButtonRight.tscn")
const BUTTONLEFT=preload("res://Scenes/Objects/Buttons/ButtonLeft.tscn")
const BUTTONUP=preload("res://Scenes/Objects/Buttons/ButtonUp.tscn")
const BUTTONDOWN=preload("res://Scenes/Objects/Buttons/ButtonDown.tscn")
const MARKER=preload("res://Scenes/Objects/reactionPacketMarker.tscn")
const SPLAT=preload("res://Scenes/Objects/FX/splat.tscn")
enum Score{GOOD, OKAY, BAD}

@onready var animatedSprite=$HitZoneAnimatedSprite2D
@onready var spawnPoint=$SpawnPoint
@onready var inputRecorder=get_parent().get_parent().find_child("InputRecorder")
@onready var chat=get_parent().find_child("Chat")
@onready var failTimer=$FailTimer #is started whenever a wrong input is detected. if another wrong input is detected BEFORE the timer is over, the game is over. otherwise, the wait time increases

@export var failTimerIncreasePerFail=1.1

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
var buttonSequence=[]#keep track of current buttons spawned, so that they can be removed in case of too early button press
var goodHit=false
var arrowSpawnID = 0
var currentButtonToEvaluate

#abstraction for reactions
var correctReactionPacket=true
var countReactionPacket=0
var reactionIndex=0#when going through previous reactions
var reactionArray=[]
var currentPacketDuration=0.0

var countMarker=0#keep track if current marker is start or end marker
var lastButtonSpawned

var debuglastButton=0

func _ready():
	countReactionPacket=0
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
			
func spawnButton():
	if arrowSpawnID % Global.difficulty == 0:
		var spawnIndex=randi()%numberOfButtonPrompts
		var newButtonPrompt=buttonPrompts[spawnIndex].instantiate()
		newButtonPrompt.global_position=spawnPoint.global_position
		get_parent().call_deferred("add_child",newButtonPrompt)
		buttonSequence.append(newButtonPrompt)
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
	var newMarker=MARKER.instantiate()
	newMarker.global_position=spawnPoint.global_position
	get_parent().call_deferred("add_child",newMarker)
	newMarker.setVisible(Global.developerMode)
	if end and lastButtonSpawned!=null:
		#print("last button detected ",debuglastButton)
		debuglastButton+=1
		lastButtonSpawned.lastButton=true

func _on_midi_player_arrows_midi_event(_channel: Variant, event: Variant) -> void:
	if event.type==144:
		if event.velocity==1:
			spawnMarker(false)
		elif event.velocity==2:
			spawnMarker(true)
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
			chat.initiateSendReactionMessage(reaction)
		else:
			reaction=RT.dirToInt(RT.Emotion.NONE)#the none reaction
			inputRecorder.reactionFailed(currentPacketDuration)
			currentPacketDuration = 0.0
			Global.packetToBeDropped[countReactionPacket-1] = true
		Global.currentStreamer.react(reaction)
		
		inputRecorder.appendRecordedReaction(reaction)
		currentButtonToEvaluate=null
		correctReactionPacket = true
			
func evaluateScore(buttonPrompt,correctInput=true):
	var splat = SPLAT.instantiate()
	get_parent().add_child(splat)
	splat.global_position = $UI/SplatSpawnPos.global_position
	var scoreChange
	if goodHit&&correctInput&&buttonPrompt!=null:#correct input in hitzone
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
		buttonSequence.pop_front().queue_free()
		
	else:#either incorrect input, no input at all (too late), or way too early
		correctReactionPacket=false
		playScoreDecrease()
		scoreChange=calculateScoreChange(Score.BAD)
		Global.score-=scoreChange
		splat.call_deferred("setText", 0)
	if buttonPrompt!=null and buttonPrompt.lastButton==true:
		react(correctReactionPacket)
	if(Global.score<=0):
		gameOver()
	

func gameOver():
	if !Global.developerMode: 
		get_tree().call_deferred("change_scene_to_file","res://Scenes/gameOver.tscn")
		Global.stopMetronome()
		Global.stopMetronomeArrows()
	
		
func registerInput(inputString):
	if currentButtonToEvaluate!=null:
		if currentButtonToEvaluate.getInput()==inputString:
			evaluateScore(currentButtonToEvaluate,true)
	else: 
		evaluateScore(null,false)
		
func dealWithMarker():
	firstPacketStarted = true
	if countMarker%2==1:
		#startmarker
		countReactionPacket += 1
		#print("count increased: ",countReactionPacket)
		currentPacketDuration = 0.0
	countMarker+=1
		
func _on_good_area_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("PacketMarker"):
		dealWithMarker()
	else:
		goodHit=true
		if buttonSequence.size() > 0 and buttonSequence.front()!=null:
			currentButtonToEvaluate=buttonSequence.front()
			area.get_parent().hitZoneEnter(true)
	
func _on_good_area_area_exited(area: Area2D) -> void:
	if !area.get_parent().is_in_group("PacketMarker"):
		goodHit=false
		
func _on_late_area_area_entered(area: Area2D) -> void:
	if !area.get_parent().is_in_group("PacketMarker"):
		evaluateScore(currentButtonToEvaluate,false)
		buttonSequence.pop_front().queue_free()


func _on_fail_timer_timeout() -> void:
	failTimer.wait_time=failTimer.wait_time*failTimerIncreasePerFail
	failTimer.stop()
