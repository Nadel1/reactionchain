extends Node2D

@onready var midiPlayerMusic=$MidiPlayerMusic
@onready var scoreLabel=$ScoreLabel

func _on_start_playing_music_timer_timeout() -> void:
	midiPlayerMusic.playing=true
	midiPlayerMusic.play()

func updateScore(value):
	scoreLabel.text="Score: "+str(value)
