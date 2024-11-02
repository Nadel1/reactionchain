extends Node2D

const BUTTONRIGHT=preload("res://Scenes/Objects/Buttons/ButtonRight.tscn")
const BUTTONLEFT=preload("res://Scenes/Objects/Buttons/ButtonLeft.tscn")
const BUTTONUP=preload("res://Scenes/Objects/Buttons/ButtonUp.tscn")
const BUTTONDOWN=preload("res://Scenes/Objects/Buttons/ButtonDown.tscn")

@onready var spawnTimerPackets=$SpawnTimerPackets
@onready var spawnTimerButtons=$SpawnTimerButtons
@onready var spawnPoint=$SpawnPoint

@export var buttonsInPacket=5

var buttonPrompts=[BUTTONRIGHT,BUTTONLEFT,BUTTONUP,BUTTONDOWN]
var numberOfButtonPrompts=4
var buttonsInCurrentPacket=0
var buttonSequence=[]#keep track of current buttons spawned, so that they can be removed in case of too early button press
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnTimerPackets.start()

func spawnButton():
	var spawnIndex=randi()%numberOfButtonPrompts
	var newButtonPrompt=buttonPrompts[spawnIndex].instantiate()
	newButtonPrompt.position=spawnPoint.global_position
	get_parent().call_deferred("add_child",newButtonPrompt)
	buttonSequence.append(newButtonPrompt)
	buttonsInCurrentPacket+=1
	if buttonsInCurrentPacket>=buttonsInPacket:#stop spawning and wait for next packet
		spawnTimerPackets.start()
		spawnTimerButtons.stop()
		buttonsInCurrentPacket=0
		print("waiting for next packet")
	else:
		spawnTimerButtons.start()
	
func removeFirstButtonPrompt():
	var firstButtonPrompt= buttonSequence.pop_front()
	if firstButtonPrompt!=null:
		firstButtonPrompt.queue_free()
	


func _on_spawn_timer_packets_timeout() -> void:
	spawnButton()


func _on_spawn_timer_buttons_timeout() -> void:
	spawnButton()
