extends Node2D

@onready var midiPlayerMusic=$MidiPlayerMusic
@onready var midiPlayerArrows=$MidiPlayerArrows
@onready var startPlayingMusicTimer=$StartPlayingMusicTimer
@onready var EOLStopPlayingMusicTimer=$EOLStopPlayingMusicTimer
@onready var scoreLabel=$ScoreLabel

@export var musicDelay=5

func _on_start_playing_music_timer_timeout() -> void:
	midiPlayerMusic.playing=true
	midiPlayerMusic.play()

func _ready():
	startPlayingMusicTimer.set_wait_time(musicDelay)
	
func updateScore(value):
	scoreLabel.text="Score: "+str(value)
	
func _on_eol_stop_spawning_arrows_timer_timeout() -> void:
	midiPlayerArrows.playing=false
	EOLStopPlayingMusicTimer.set_wait_time(musicDelay)#so that the music ends with the same delay it started with
	EOLStopPlayingMusicTimer.start()
	


func _on_eol_stop_playing_music_timer_timeout() -> void:
	midiPlayerMusic.playing=false
