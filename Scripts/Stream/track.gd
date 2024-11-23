extends Node2D

const BUTTONRIGHT=preload("res://Scenes/Objects/Buttons/ButtonRight.tscn")
const BUTTONLEFT=preload("res://Scenes/Objects/Buttons/ButtonLeft.tscn")
const BUTTONUP=preload("res://Scenes/Objects/Buttons/ButtonUp.tscn")
const BUTTONDOWN=preload("res://Scenes/Objects/Buttons/ButtonDown.tscn")
const MARKER=preload("res://Scenes/Objects/reactionPacketMarker.tscn")

@onready var animatedSprite=$HitZoneAnimatedSprite2D
@onready var spawnPoint=$SpawnPoint
@onready var judgingUI=$UI/JudgingPrompt
@onready var inputRecorder=get_parent().get_parent().find_child("InputRecorder")

@export var scoreChangeGoodHit=10
@export var scoreChangeOkayHit=5
@export var scoreChangeBadHit=-5

var buttonPrompts=[BUTTONRIGHT,BUTTONLEFT,BUTTONUP,BUTTONDOWN]
var numberOfButtonPrompts=4
var buttonsInCurrentPacket=0
var buttonSequence=[]#keep track of current buttons spawned, so that they can be removed in case of too early button press
var goodHit=false
var judgingPromptsGood=["YEY","YIPPIE","WAHOO"]
var judgingPromptsOkay=["okay"]
var judgingPromptsBad=["uff","bad"]
var totalNumberCorrectInputs=0
var arrowSpawnID = 0

#abstraction for reactions
var correctInputs=4
var currentCorrectInputs=0
var correctReactionPacket=false
var countReactionPacket=-1
var reactionIndex=0#when going through previous reactions
var reactionArray=[]
var currentPacketDuration=0.0
var firstPacketStarted=false

	
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
			print("bullshit was pressed")
			evaluateScore(null,false)
			
func spawnButton():
	if arrowSpawnID % Global.difficulty == 0:
		var spawnIndex=randi()%numberOfButtonPrompts
		var newButtonPrompt=buttonPrompts[spawnIndex].instantiate()
		newButtonPrompt.position=spawnPoint.global_position
		get_parent().call_deferred("add_child",newButtonPrompt)
		buttonSequence.append(newButtonPrompt)
	arrowSpawnID += 1

func spawnMarker():
	var newMarker=MARKER.instantiate()
	newMarker.position=spawnPoint.global_position
	get_parent().call_deferred("add_child",newMarker)

func _on_midi_player_arrows_midi_event(_channel: Variant, event: Variant) -> void:
	if event.type==144:
		if event.velocity==1:
			spawnMarker()
		elif event.velocity>1:
			spawnButton()

func playScoreDecrease():#animate hitzone and maybe later add more music here? 
	animatedSprite.play("wrongHit")
	Global.currentTrackHandler.failInput()

func playScoreIncrease():
	animatedSprite.play("hit")
	

func react():
	if Global.currentStreamer!=null:
		var reaction
		if Global.currentStreamIndex==0 ||countReactionPacket>=Global.recordingsReaction[Global.currentStreamIndex-1].size():
			reaction=RT.intToDir(randi()%4)#randomly select one of the four emotions if first streamer or no reactions to pull from
		else:
			reaction=Global.recordingsReaction[Global.currentStreamIndex-1][countReactionPacket][1]
		Global.currentStreamer.react(reaction)
		inputRecorder.appendRecordedReaction(reaction)
			
			
func evaluateScore(buttonPrompt,correctInput=true):
	if goodHit&&correctInput&&buttonPrompt!=null:#correct input in hitzone
		if buttonPrompt.goodHit:
			Global.score+=scoreChangeGoodHit
			judgingUI.text="[center]"+judgingPromptsGood.pick_random()+"[/center]"
		else: 
			Global.score+=scoreChangeOkayHit
			judgingUI.text="[center]"+judgingPromptsOkay.pick_random()+"[/center]"
		playScoreIncrease()
		buttonSequence.pop_front().queue_free()
		currentCorrectInputs+=1
		totalNumberCorrectInputs+=1
	else:#either incorrect input, no input at all (too late), or way too early
		playScoreDecrease()
		Global.score+=scoreChangeBadHit
		judgingUI.text="[center]"+judgingPromptsBad.pick_random()+"[/center]"
		currentCorrectInputs=0
		correctReactionPacket=false
	if get_parent()!=null:
		find_parent("Stream").updateScore()
	

func registerInput(inputString):
	if buttonSequence.is_empty()==true:
		evaluateScore(null,false)#substract points when input for example at end of level
		
	var buttonPrompt=buttonSequence.front()
	if buttonPrompt!=null:
		if buttonPrompt.getInput()==inputString:
			evaluateScore(buttonPrompt)
		else: 
			evaluateScore(buttonPrompt,false)
		
func _on_good_area_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("PacketMarker"):
		if correctReactionPacket:#last reaction paket was correct, as the start of a new packet indicates the end of the last one
			react()
		elif firstPacketStarted:
			Global.inputRecorder.reactionFailed(currentPacketDuration)
		firstPacketStarted = true
		correctReactionPacket = true
		countReactionPacket += 1
		currentPacketDuration = 0.0
	else:
		goodHit=true
		if buttonSequence.front()!=null:
			buttonSequence.front().hitZoneEnter(true)
	
func _on_good_area_area_exited(area: Area2D) -> void:
	if !area.get_parent().is_in_group("PacketMarker"):
		goodHit=false
		
func _on_late_area_area_entered(area: Area2D) -> void:
	if !area.get_parent().is_in_group("PacketMarker"):
		evaluateScore(null,false)
		buttonSequence.pop_front().queue_free()

func _on_eol_stop_spawning_arrows_timer_timeout() -> void:
	spawnMarker()

func _process(delta: float) -> void:
	if firstPacketStarted:
		currentPacketDuration += delta
