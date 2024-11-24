extends Node2D

@onready var midiPlayerArrows=$MidiPlayerArrows
@onready var startPlayingMusicTimer=$StartPlayingMusicTimer
@onready var EOLStopPlayingMusicTimer=$EOLStopPlayingMusicTimer
@onready var switchSceneTimer=$SwitchSceneTimer
@onready var scoreLabel=$UI/ScoreLabel
@onready var inputRecorder=$InputRecorder
var recording = preload("res://Scenes/Stream/recording.tscn")
var startVideo = preload("res://Scenes/Stream/startVideo.tscn")

#preload streamers
const STREAMER0=preload("res://Scenes/Objects/Streamers/streamerBasic0.tscn")
const STREAMER1=preload("res://Scenes/Objects/Streamers/streamerBasic1.tscn")
const STREAMER2=preload("res://Scenes/Objects/Streamers/streamerBasic2.tscn")
var allStreamers=[STREAMER1,STREAMER2]
var currentStreamerIndex=0
var currentStreamer=null


var counterForArrowsPlayer=0#counter which index from musicToPlay should be inserted next
var index

@export var musicDelay=6
var trackPlayers : Array[TrackPlaybackHandler]

func _on_start_playing_music_timer_timeout() -> void:
	$TrackPlaybackHandler.call_deferred("start")
	for player in trackPlayers:
		player.call_deferred("start")
		
	#for i in range(0, AudioServer.get_bus_count()):
	#	print(AudioServer.get_bus_name(i))


func prepareStreamer():
	if Global.streamerIndices.size()>0 and currentStreamerIndex==Global.streamerIndices[Global.currentStreamIndex-1]: #making sure we dont pick the same streamer twice in a row
		if currentStreamerIndex==allStreamers.size()-1:
			currentStreamer=allStreamers[0]
		else:
			currentStreamer=allStreamers[currentStreamerIndex+1]
		currentStreamerIndex=allStreamers.find(currentStreamer)
		
	currentStreamer=allStreamers[currentStreamerIndex].instantiate()
	currentStreamer.position=$UI/StreamerPlaceholder.position
	currentStreamer.scale=$UI/StreamerPlaceholder.scale
	$UI/StreamerPlaceholder.visible = false
	$UI.call_deferred("add_child",currentStreamer)
	inputRecorder.setStreamer(currentStreamer)
	
func prepareArrows():
	var firstSnippet = Global.musicTracks[Global.currentStreamIndex][0]
	midiPlayerArrows.set_file(firstSnippet)
	midiPlayerArrows.play()
	
func _ready():
	Global.prepareMusic()
	prepareStreamer()
	prepareArrows()
	startPlayingMusicTimer.set_wait_time(musicDelay)
	updateScore()
	$TrackPlaybackHandler.setIndex(Global.currentStreamIndex)
	Global.currentTrackHandler = $TrackPlaybackHandler
	midiPlayerArrows.setName("Arrows")
	#midiPlayerArrows.set_file($TrackPlaybackHandler/AudioTrackProvider.getTrackCorrect(Global.currentStreamIndex))
	#midiPlayerArrows.play()
	index=Global.currentStreamIndex
	
	var currentNode = $UI/VideoFrame
	if Global.currentStreamIndex > 0:
		for i in range(0,Global.currentStreamIndex):
			var recursionInstance = recording.instantiate()
			var lastStreamer=allStreamers[Global.streamerIndices[Global.currentStreamIndex-1-i]].instantiate()
			lastStreamer.position=$UI/StreamerPlaceholder.position
			lastStreamer.scale=$UI/StreamerPlaceholder.scale
			recursionInstance.setStreamer(lastStreamer)
			recursionInstance.add_child(lastStreamer)
			recursionInstance.setIndex((Global.currentStreamIndex-1)-i)
			currentNode.find_child("Content").add_child(recursionInstance)
			var trackPlayer = recursionInstance.find_child("TrackPlaybackHandler")
			if trackPlayer != null:
				trackPlayers.append(trackPlayer)
				trackPlayer.find_child("MidiPlayerCorrect").bus = "Correct"+str((Global.currentStreamIndex-1)-i)
				trackPlayer.find_child("MidiPlayerFail").bus = "Fail"+str((Global.currentStreamIndex-1)-i)
			currentNode = recursionInstance
	var video = startVideo.instantiate()
	currentNode.find_child("Content").add_child(video)
	$Transition.play("zoomOut")
	Global.currentStreamer=currentStreamer#so that implementing reactions is easier
	Global.streamerIndices.append(currentStreamerIndex)

func _process(delta: float) -> void:
	$UI/TrackIndicatorWrong.scale.y = $TrackPlaybackHandler.fade
	$UI/TrackIndicatorRight.scale.y = 1.0-$TrackPlaybackHandler.fade
	
func updateScore():
	scoreLabel.text="Score: "+str(Global.score)
	
func _on_eol_stop_spawning_arrows_timer_timeout() -> void:
	midiPlayerArrows.playing=false
	EOLStopPlayingMusicTimer.set_wait_time(musicDelay)#so that the music ends with the same delay it started with
	EOLStopPlayingMusicTimer.start()
	
func _on_eol_stop_playing_music_timer_timeout() -> void:
	$TrackPlaybackHandler.stop()
	for trackPlayer in trackPlayers:
		trackPlayer.stop()
	switchSceneTimer.start()
	
func _on_switch_scene_timer_timeout() -> void:
	Global.currentStreamIndex += 1
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")


func _on_track_playback_handler_layer_finished() -> void:
	switchSceneTimer.start()


func _on_midi_player_arrows_finished() -> void:
	counterForArrowsPlayer+=1
	if counterForArrowsPlayer<Global.musicTracks[index].size():
		midiPlayerArrows.set_file(Global.musicTracks[index][counterForArrowsPlayer])
		midiPlayerArrows.set_file(Global.musicTracks[index][counterForArrowsPlayer])
		midiPlayerArrows.play()
