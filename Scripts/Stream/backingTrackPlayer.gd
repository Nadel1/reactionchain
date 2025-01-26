extends Node

@export var players : Array[MidiPlayer] #exclude drums
var playIndex = 0
var newVolume = -30

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
	for player in players:
		player.volume_db = newVolume
	if playIndex % 2 == 0:
		for player in players:
			player.play()
	playIndex += 1

func setVolume(volume : float):
	newVolume = volume
