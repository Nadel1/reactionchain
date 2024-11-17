extends Node2D

const BUTTONRIGHT=preload("res://Scenes/Objects/Buttons/ButtonRight.tscn")
const BUTTONLEFT=preload("res://Scenes/Objects/Buttons/ButtonLeft.tscn")
const BUTTONUP=preload("res://Scenes/Objects/Buttons/ButtonUp.tscn")
const BUTTONDOWN=preload("res://Scenes/Objects/Buttons/ButtonDown.tscn")


@onready var animatedSprite=$HitZoneAnimatedSprite2D
@onready var spawnPoint=$SpawnPoint
@onready var judgingUI=$UI/JudgingPrompt

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

#abstraction for reactions
var correctInputs=4
var currentCorrectInputs=0
	
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
			evaluateScore(false)
			
func spawnButton():
	var spawnIndex=randi()%numberOfButtonPrompts
	var newButtonPrompt=buttonPrompts[spawnIndex].instantiate()
	newButtonPrompt.position=spawnPoint.global_position
	get_parent().call_deferred("add_child",newButtonPrompt)
	buttonSequence.append(newButtonPrompt)

func _on_midi_player_arrows_midi_event(_channel: Variant, event: Variant) -> void:
	if event.type==144:#no idea why it has to be this type
		spawnButton()

func playScoreDecrease():#animate hitzone and maybe later add more music here? 
	animatedSprite.play("wrongHit")

func playScoreIncrease():
	animatedSprite.play("hit")
	

func react():
	if currentCorrectInputs==correctInputs:
		if Global.currentStreamer!=null:
			Global.currentStreamer.react(RT.Emotion.POG)
			var newEntry=ReactionRecord.new()
			newEntry.inputIndex=totalNumberCorrectInputs
			newEntry.reaction=RT.Emotion.POG
			Global.reactions.append(newEntry)
			print("appended entry with value: ", totalNumberCorrectInputs)
			currentCorrectInputs=0
			
func evaluateScore(buttonPrompt,correctInput=true):
	if correctInput && goodHit&&buttonPrompt!=null:#correct input in hitzone
		if buttonPrompt.goodHit:
			Global.score+=scoreChangeGoodHit
			playScoreIncrease()
			judgingUI.text="[center]"+judgingPromptsGood.pick_random()+"[/center]"
			currentCorrectInputs+=1
			totalNumberCorrectInputs+=1
			print("totalNumbercorrectInputs: ", totalNumberCorrectInputs)
		else: 
			Global.score+=scoreChangeOkayHit
			playScoreIncrease()
			judgingUI.text="[center]"+judgingPromptsOkay.pick_random()+"[/center]"
			currentCorrectInputs+=1
			totalNumberCorrectInputs+=1
			print("totalNumbercorrectInputs: ", totalNumberCorrectInputs)
	else:#either incorrect input, or no input at all (too late)
		playScoreDecrease()
		Global.score+=scoreChangeBadHit
		judgingUI.text="[center]"+judgingPromptsBad.pick_random()+"[/center]"
		currentCorrectInputs=0
	if get_parent()!=null:
		find_parent("Stream").updateScore()
	react()

func registerInput(inputString):
	if buttonSequence.is_empty()==true:
		evaluateScore(null,false)#substract points when input for example at end of level
		
	var buttonPrompt=buttonSequence.front()
	if buttonPrompt!=null:
		if buttonPrompt.getInput()==inputString:
			evaluateScore(buttonPrompt)
		else: 
			evaluateScore(buttonPrompt,false)
	if goodHit==true:	
		buttonSequence.pop_front().queue_free()
		
func _on_good_area_area_entered(_area: Area2D) -> void:
	goodHit=true
	if buttonSequence.front()!=null:
		buttonSequence.front().hitZoneEnter(true)
	
func _on_good_area_area_exited(_area: Area2D) -> void:
	goodHit=false
		
func _on_late_area_area_entered(_area: Area2D) -> void:
	buttonSequence.pop_front().queue_free()
	evaluateScore(null,false)


func _on_hit_zone_animated_sprite_2d_animation_finished() -> void:
	animatedSprite.play("default")
