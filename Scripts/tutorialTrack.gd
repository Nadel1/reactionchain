extends Node

const BUTTONRIGHT=preload("res://Scenes/Objects/Buttons/ButtonRight.tscn")
const BUTTONLEFT=preload("res://Scenes/Objects/Buttons/ButtonLeft.tscn")
const BUTTONUP=preload("res://Scenes/Objects/Buttons/ButtonUp.tscn")
const BUTTONDOWN=preload("res://Scenes/Objects/Buttons/ButtonDown.tscn")
const BUTTONS = [BUTTONUP,BUTTONRIGHT,BUTTONDOWN,BUTTONLEFT]

@export var arrowsPlayer : MidiPlayer
@export var musicPlayer : MidiPlayer
@export var Asnippets : Array[TrackSnippet]
@export var Bsnippets : Array[TrackSnippet]
@export var spawnPoint : Node2D
var musicTrack = []
var stopIndex = -1

signal successfulHit

func _ready() -> void:
	arrowsPlayer.setName("Arrows")
	musicPlayer.setName("Music")
	Global.tactArrows.connect(arrowsTact)
	Global.tact.connect(musicTact)
	var A = true
	for i in range(0,6):
		musicTrack.append(Asnippets.pick_random() if A else Bsnippets.pick_random())
		A = !A

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

func compareInput(prompt, inputString):
	return prompt.getInput() == inputString

func isPrompt(area):
	return area.get_parent().is_in_group("InputPrompt")

func registerInput(inputString):
	var areasInRange = $HitZoneAnimatedSprite2D/GoodArea.get_overlapping_areas().filter(isPrompt)
	if areasInRange.size() > 0:
		for area in areasInRange:
			if compareInput(area.get_parent(), inputString):
				area.get_parent().call_deferred("queue_free")
				successfulHit.emit()
				return

func arrowsTact(snippetIndex):
	if stopIndex < 0 or snippetIndex < stopIndex:
		arrowsPlayer.file = musicTrack[snippetIndex % musicTrack.size()].getLayer(0)
		arrowsPlayer.play()

func musicTact(snippetIndex):
	if stopIndex < 0 or snippetIndex < stopIndex:
		musicPlayer.file = musicTrack[snippetIndex % musicTrack.size()].getLayer(0)
		musicPlayer.play()

func spawnButton():
	var newButtonPrompt = BUTTONS.pick_random().instantiate()
	newButtonPrompt.global_position = spawnPoint.global_position
	get_parent().call_deferred("add_child",newButtonPrompt)

func stopMusic():
	stopIndex = Global.arrowSnippetIndex

func _on_start_spawning_arrows_timer_timeout() -> void:
	Global.startMetronomeArrows()

func _on_good_area_area_entered(area: Area2D) -> void:
	area.get_parent().hitZoneEnter(true)

func _on_midi_player_arrows_midi_event(_channel: Variant, event: Variant) -> void:
	if event.type==144 and event.velocity > 2:
		spawnButton()

func _on_late_area_area_entered(area: Area2D) -> void:
	area.get_parent().call_deferred("queue_free")
	$LateArea/TrashCan.play("newTrash")
