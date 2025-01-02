extends Node

var players = []
var playIndex = 0

func _ready() -> void:
	players = get_children()
	$MidiPlayerBass1.setName("Bass1")
	$MidiPlayerBass2.setName("Bass2")
	$MidiPlayerChords.setName("Chords")
	for player in players:
		player.play_speed = Global.playbackSpeed
	Global.tact.connect(tact)

func tact():
	if playIndex % 2 == 0:
		for player in players:
			player.play()
	playIndex += 1
