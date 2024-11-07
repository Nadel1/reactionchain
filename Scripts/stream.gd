extends Node2D

@onready var midiPlayerMusic=$MidiPlayerMusic
@onready var midiPlayerArrows=$MidiPlayerArrows
@onready var startPlayingMusicTimer=$StartPlayingMusicTimer
@onready var EOLStopPlayingMusicTimer=$EOLStopPlayingMusicTimer
@onready var switchSceneTimer=$SwitchSceneTimer
@onready var scoreLabel=$ScoreLabel
var recording = preload("res://Scenes/Stream/recording.tscn")

@export var musicDelay=5

func _on_start_playing_music_timer_timeout() -> void:
	midiPlayerMusic.playing=true
	midiPlayerMusic.play()

func _ready():
	startPlayingMusicTimer.set_wait_time(musicDelay)
	updateScore()
	if Global.currentStreamIndex > 0:
		var currentNode = $VideoFrame
		for i in range(0,Global.currentStreamIndex):
			var recursionInstance = recording.instantiate()
			recursionInstance.index = (Global.currentStreamIndex-1)-i
			currentNode.find_child("Content").add_child(recursionInstance)
			currentNode = recursionInstance
	
func updateScore():
	scoreLabel.text="Score: "+str(Global.score)
	
func _on_eol_stop_spawning_arrows_timer_timeout() -> void:
	midiPlayerArrows.playing=false
	EOLStopPlayingMusicTimer.set_wait_time(musicDelay)#so that the music ends with the same delay it started with
	EOLStopPlayingMusicTimer.start()
	
func _on_eol_stop_playing_music_timer_timeout() -> void:
	midiPlayerMusic.playing=false
	switchSceneTimer.start()
	
func _on_switch_scene_timer_timeout() -> void:
	Global.currentStreamIndex += 1
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")
