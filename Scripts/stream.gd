extends Node2D

@onready var midiPlayerMusic=$MidiPlayerMusic
@onready var midiPlayerArrows=$MidiPlayerArrows
@onready var startPlayingMusicTimer=$StartPlayingMusicTimer
@onready var EOLStopPlayingMusicTimer=$EOLStopPlayingMusicTimer
@onready var switchSceneTimer=$SwitchSceneTimer
@onready var scoreLabel=$UI/ScoreLabel
@onready var inputRecorder=$InputRecorder
var recording = preload("res://Scenes/Stream/recording.tscn")
var startVideo = preload("res://Scenes/Stream/startVideo.tscn")

#preload streamers
var streamer0=preload("res://Scenes/Objects/Streamers/streamer.tscn")
var streamer1=preload("res://Scenes/Objects/Streamers/streamerBasic1.tscn")
var allStreamers=[streamer0,streamer1]
var lastStreamerIndex=-1
var currentStreamerIndex=-1
var lastStreamer=null


@export var musicDelay=6
var midiPlayers : Array[MidiPlayer]

func _on_start_playing_music_timer_timeout() -> void:
	midiPlayerMusic.playing=true
	midiPlayerMusic.play()
	for player in midiPlayers:
		player.play()

func prepareStreamer():
	var currentStreamer=allStreamers.pick_random()
	#currentStreamerIndex=allStreamers.find(currentStreamer)
	#if currentStreamerIndex==lastStreamerIndex: #making sure we dont pick the same streamer twice in a row
#		if currentStreamerIndex==0:
#			currentStreamer=allStreamers[1]
#		elif currentStreamerIndex==allStreamers.size():
#			currentStreamer=allStreamers[0]
#		else:
#			currentStreamer=allStreamers[currentStreamerIndex+1]
#		currentStreamerIndex=allStreamers.find(currentStreamer)
	#lastStreamerIndex=currentStreamerIndex
	#lastStreamer=currentStreamer
	currentStreamer.instantiate()
	get_parent().call_deferred("add_child",currentStreamer)
	inputRecorder.setStreamer(currentStreamer)
	
	
func _ready():
	prepareStreamer()
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
			recursionInstance.setStreamer(lastStreamer)
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
