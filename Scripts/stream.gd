extends Node2D

@onready var midiPlayerMusic=$MidiPlayerMusic

func _on_start_playing_music_timer_timeout() -> void:
	midiPlayerMusic.playing=true
	midiPlayerMusic.play()
