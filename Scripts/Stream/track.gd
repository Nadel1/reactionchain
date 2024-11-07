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

var buttonPrompts=[BUTTONRIGHT,BUTTONLEFT,BUTTONUP,BUTTONDOWN]
var numberOfButtonPrompts=4
var buttonsInCurrentPacket=0
var buttonSequence=[]#keep track of current buttons spawned, so that they can be removed in case of too early button press
var goodHit=false
var buttonPrompt=null

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
			
func spawnButton():
	var spawnIndex=randi()%numberOfButtonPrompts
	var newButtonPrompt=buttonPrompts[spawnIndex].instantiate()
	newButtonPrompt.position=spawnPoint.global_position
	get_parent().call_deferred("add_child",newButtonPrompt)
	buttonSequence.append(newButtonPrompt)
	
func removeFirstButtonPrompt():
	var firstButtonPrompt= buttonSequence.pop_front()
	if firstButtonPrompt!=null:
		firstButtonPrompt.queue_free()
	

func _on_midi_player_arrows_midi_event(channel: Variant, event: Variant) -> void:
	if event.type==144:#no idea why it has to be this type
		spawnButton()


func changeScore(addToScore):
	pass

func registerInput(inputString):
	removeFirstButtonPrompt()
	if buttonPrompt!=null: #check to see if there is a button in the hitzone
		if buttonPrompt.getInput()==inputString:
			animatedSprite.play("hit")
			print("righ timing, right input")
		else: 
			animatedSprite.play("default")
			print("righ timing, wrong input")
		buttonPrompt=null
	else:
		print("wrong timing")
		
func _on_good_area_area_entered(area: Area2D) -> void:
	buttonPrompt=area.get_parent()
	buttonPrompt.hitZoneEnter(true)
	goodHit=true


func _on_good_area_area_exited(area: Area2D) -> void:
	if buttonPrompt!=null:
		removeFirstButtonPrompt()
	buttonPrompt=null
	goodHit=false
