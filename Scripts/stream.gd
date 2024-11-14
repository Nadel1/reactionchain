extends Node2D

@onready var midiPlayerMusic=$MidiPlayerMusic
@onready var midiPlayerArrows=$MidiPlayerArrows
@onready var startPlayingMusicTimer=$StartPlayingMusicTimer
@onready var EOLStopPlayingMusicTimer=$EOLStopPlayingMusicTimer
@onready var switchSceneTimer=$SwitchSceneTimer
@onready var scoreLabel=$UI/ScoreLabel
var recording = preload("res://Scenes/Stream/recording.tscn")
var startVideo = preload("res://Scenes/Stream/startVideo.tscn")

@export var musicDelay=5
var midiPlayers : Array[MidiPlayer]

func _on_start_playing_music_timer_timeout() -> void:
	midiPlayerMusic.playing=true
	midiPlayerMusic.play()
	for player in midiPlayers:
		player.play()

func _ready():
	startPlayingMusicTimer.set_wait_time(musicDelay)
	updateScore()
	
	var audioFile = $AudioTrackProvider.getTrack(Global.currentStreamIndex)
	var instrument = $AudioTrackProvider.getSoundFont(Global.currentStreamIndex)
	if audioFile != null:
		midiPlayerMusic.set_file(audioFile)
		midiPlayerMusic.set_soundfont(instrument)
		midiPlayerArrows.set_file(audioFile)
		midiPlayerArrows.play()
		
	var currentNode = $UI/VideoFrame
	if Global.currentStreamIndex > 0:
		for i in range(0,Global.currentStreamIndex):
			var recursionInstance = recording.instantiate()
			recursionInstance.setIndex((Global.currentStreamIndex-1)-i)
			currentNode.find_child("Content").add_child(recursionInstance)
			var midiPlayer = recursionInstance.find_child("MidiPlayer")
			if midiPlayer != null:
				midiPlayers.append(midiPlayer)
			currentNode = recursionInstance
	var video = startVideo.instantiate()
	currentNode.find_child("Content").add_child(video)
	$Transition.play("zoomOut")
	
func updateScore():
	scoreLabel.text="Score: "+str(Global.score)
	
func _on_eol_stop_spawning_arrows_timer_timeout() -> void:
	midiPlayerArrows.playing=false
	EOLStopPlayingMusicTimer.set_wait_time(musicDelay)#so that the music ends with the same delay it started with
	EOLStopPlayingMusicTimer.start()
	
func _on_eol_stop_playing_music_timer_timeout() -> void:
	midiPlayerMusic.playing=false
	for player in midiPlayers:
		player.playing = false
	switchSceneTimer.start()
	
func _on_switch_scene_timer_timeout() -> void:
	Global.currentStreamIndex += 1
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")
