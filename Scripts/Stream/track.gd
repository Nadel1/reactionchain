extends Node2D

const BUTTONRIGHT=preload("res://Scenes/Objects/Buttons/ButtonRight.tscn")
const BUTTONLEFT=preload("res://Scenes/Objects/Buttons/ButtonLeft.tscn")
const BUTTONUP=preload("res://Scenes/Objects/Buttons/ButtonUp.tscn")
const BUTTONDOWN=preload("res://Scenes/Objects/Buttons/ButtonDown.tscn")

@onready var spawnTimer=$SpawnTimer
@onready var spawnPoint=$SpawnPoint

var buttonPrompts=[BUTTONRIGHT,BUTTONLEFT,BUTTONUP,BUTTONDOWN]
var numberOfButtonPrompts=4
var buttonSequence=[]#keep track of current buttons spawned, so that they can be removed in case of too early button press
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawnTimer.start()

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
	
func _on_spawn_timer_timeout() -> void:
	spawnButton()
	spawnTimer.start()
