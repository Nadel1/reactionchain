extends Node

@export var players : Array[MidiPlayer] #exclude drums
var playIndex = 0

func _ready() -> void:
	$MidiPlayerBass1.setName("Bass1")
	$MidiPlayerBass2.setName("Bass2")
	$MidiPlayerChords.setName("Chords")
	$MidiPlayerDrums.setName("Drums")
	$MidiPlayerDrums.play_speed = Global.playbackSpeed
	for player in players:
		player.play_speed = Global.playbackSpeed
	Global.tact.connect(tact)

func tact(_snippetIndex):
	if playIndex % 2 == 0:
		for player in players:
			player.play()
	playIndex += 1
