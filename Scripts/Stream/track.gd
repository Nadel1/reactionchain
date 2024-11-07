extends Node2D

const BUTTONRIGHT=preload("res://Scenes/Objects/Buttons/ButtonRight.tscn")
const BUTTONLEFT=preload("res://Scenes/Objects/Buttons/ButtonLeft.tscn")
const BUTTONUP=preload("res://Scenes/Objects/Buttons/ButtonUp.tscn")
const BUTTONDOWN=preload("res://Scenes/Objects/Buttons/ButtonDown.tscn")


@onready var animatedSprite=$HitZoneAnimatedSprite2D
@onready var spawnTimerPackets=$SpawnTimerPackets
@onready var spawnTimerButtons=$SpawnTimerButtons
@onready var spawnPoint=$SpawnPoint

@export var score=0
@export var scoreChangeGoodHit=10
@export var scoreChangeOkayHit=5
@export var scoreChangeBadHit=-5

var buttonPrompts=[BUTTONRIGHT,BUTTONLEFT,BUTTONUP,BUTTONDOWN]
var numberOfButtonPrompts=4
var buttonsInCurrentPacket=0
var buttonSequence=[]#keep track of current buttons spawned, so that they can be removed in case of too early button press
var goodHit=false

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

func _on_midi_player_arrows_midi_event(channel: Variant, event: Variant) -> void:
	if event.type==144:#no idea why it has to be this type
		spawnButton()

func playScoreDecrease():#animate hitzone and maybe later add more music here? 
	animatedSprite.play("wrongHit")

func playScoreIncrease():
	animatedSprite.play("hit")
	
func evaluateScore(correctInput=true):
	if correctInput:
		if goodHit:#correct input in hitzone
			score+=scoreChangeGoodHit
			playScoreIncrease()
		else:#correct input not in hitzone
			score+=scoreChangeBadHit
			playScoreDecrease()
	else:#either incorrect input, or no input at all (too late)
		playScoreDecrease()
		score+=scoreChangeBadHit
	print("score: ",score)
	if get_parent()!=null:
		get_parent().updateScore(score)

func registerInput(inputString):
	var buttonPrompt=buttonSequence.front()
	if buttonPrompt!=null:
		if buttonPrompt.getInput()==inputString:
			
			evaluateScore()
		else: 
			evaluateScore(false)
		
	if goodHit==true:	
		buttonSequence.pop_front().queue_free()

		
func _on_good_area_area_entered(area: Area2D) -> void:
	goodHit=true
	buttonSequence.front().hitZoneEnter(true)
	
func _on_good_area_area_exited(area: Area2D) -> void:
	goodHit=false

func _on_late_area_area_entered(area: Area2D) -> void:
	buttonSequence.pop_front().queue_free()
	evaluateScore(false)


func _on_hit_zone_animated_sprite_2d_animation_finished() -> void:
	animatedSprite.play("default")
