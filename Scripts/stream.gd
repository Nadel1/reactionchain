extends Node2D

@onready var midiPlayerArrows=$MidiPlayerArrows
@onready var startPlayingMusicTimer=$StartPlayingMusicTimer
@onready var switchSceneTimer=$SwitchSceneTimer
@onready var inputRecorder=$InputRecorder
var recording = preload("res://Scenes/Stream/recording.tscn")
var startVideo = preload("res://Scenes/Stream/startVideo.tscn")
var gameOverPossible=true#modified by developermode

#preload streamers
const STREAMER0=preload("res://Scenes/Objects/Streamers/streamerBasic0.tscn")
const STREAMER1=preload("res://Scenes/Objects/Streamers/streamerBasic1.tscn")
const STREAMER2=preload("res://Scenes/Objects/Streamers/streamerBasic2.tscn")
var allStreamers=[STREAMER0, STREAMER1, STREAMER2]
var currentStreamerIndex=0
var currentStreamer=null
var musicToPlay=[]

var counterForArrowsPlayer=0#counter which index from musicToPlay should be inserted next
var index

#generate music track
#file path (preload doesnt work apparently with mid files)
const LAYER1SNIPPET="res://Assets/Audio/Tracks/snippets/lead1_layer1.MID"
const LAYER2SNIPPET="res://Assets/Audio/Tracks/snippets/lead1_layer2.MID"
const LAYER3SNIPPET="res://Assets/Audio/Tracks/snippets/lead1_layer3.MID"

var allSnippetsLayer1=[LAYER1SNIPPET]
var allSnippetsLayer2=[LAYER2SNIPPET]
var allSnippetsLayer3=[LAYER3SNIPPET]

var allLayers=[allSnippetsLayer1,allSnippetsLayer2,allSnippetsLayer3]

@export var lengthOfMusic=5#number of reaction packets to play
var dropPacketsIndex=0

var trackPlayers : Array[TrackPlaybackHandler]

func _on_start_playing_music_timer_timeout() -> void:
	$TrackPlaybackHandler.call_deferred("start")
	Global.startMetronome()
	for player in trackPlayers:
		player.call_deferred("start")
	

func prepareStreamer():
	currentStreamerIndex = randi() % allStreamers.size()
	if Global.streamerIndices.size()>0 and currentStreamerIndex==Global.streamerIndices[Global.currentStreamIndex-1]: #making sure we dont pick the same streamer twice in a row
		currentStreamerIndex += 1
		currentStreamerIndex %= allStreamers.size()
		
	currentStreamer=allStreamers[currentStreamerIndex].instantiate()
	currentStreamer.position=$UI/StreamerPlaceholder.position
	currentStreamer.scale=$UI/StreamerPlaceholder.scale
	currentStreamer.init(currentStreamerIndex, Global.currentStreamIndex)
	$UI/StreamerPlaceholder.visible = false
	$UI.call_deferred("add_child",currentStreamer)
	inputRecorder.setStreamer(currentStreamer)
	
func prepareMusic():
	
	var layerToChoseFrom= allLayers[Global.currentStreamIndex%allLayers.size()]#modulo only needed here for endless 
	if Global.currentStreamIndex==0:
		for i in lengthOfMusic:
			musicToPlay.append(layerToChoseFrom.pick_random())
	else:
		#play the corresponding next layer to the previous snippet or drop if needed
		for i in lengthOfMusic:
			var lastSnippet=Global.musicTracks[Global.currentStreamIndex%allLayers.size()-1][i]
			var lastIndex=allLayers[Global.currentStreamIndex%allLayers.size()-1].find(lastSnippet)
			if Global.packetsToBeDropped.size()==0:
				musicToPlay.append(layerToChoseFrom[lastIndex])
			elif Global.packetsToBeDropped[dropPacketsIndex]==lastIndex:
				musicToPlay.append(layerToChoseFrom.pick_random())
				
	Global.musicTracks.append(musicToPlay)
	
	
func prepareArrows():
	var firstSnippet = musicToPlay[0]
	midiPlayerArrows.set_file(firstSnippet)
	
	
func _ready():
	$UI/TrackIndicatorWrong.visible=Global.developerMode
	$UI/TrackIndicatorRight.visible=Global.developerMode
	Global.tactArrows.connect(nextArrowTact)
	
	prepareMusic()
	prepareStreamer()
	prepareArrows()
	$TrackPlaybackHandler.setIndex(Global.currentStreamIndex)
	Global.currentTrackHandler = $TrackPlaybackHandler
	midiPlayerArrows.setName("Arrows")
	index=Global.currentStreamIndex
	if index > 0:
		VideoCustomizer.extendTitle(index)
	
	var currentNode = $UI/VideoFrame
	currentNode.init(Global.currentStreamIndex)
	if Global.currentStreamIndex > 0:
		for i in range(0,Global.currentStreamIndex):
			var recursionInstance = recording.instantiate()
			var lastStreamer=allStreamers[Global.streamerIndices[Global.currentStreamIndex-1-i]].instantiate()
			lastStreamer.position=$UI/StreamerPlaceholder.position
			lastStreamer.scale=$UI/StreamerPlaceholder.scale
			lastStreamer.init(Global.streamerIndices[Global.currentStreamIndex-1-i], Global.currentStreamIndex-1-i)
			recursionInstance.setStreamer(lastStreamer)
			recursionInstance.add_child(lastStreamer)
			recursionInstance.setIndex((Global.currentStreamIndex-1)-i)
			currentNode.find_child("Content").add_child(recursionInstance)
			recursionInstance.find_child("VideoFrame").init((Global.currentStreamIndex-1)-i)
			var trackPlayer = recursionInstance.find_child("TrackPlaybackHandler")
			if trackPlayer != null:
				trackPlayers.append(trackPlayer)
				trackPlayer.find_child("MidiPlayerCorrect").bus = "Correct"+str((Global.currentStreamIndex-1)-i)
				trackPlayer.find_child("MidiPlayerFail").bus = "Fail"+str((Global.currentStreamIndex-1)-i)
			currentNode = recursionInstance
	var video = startVideo.instantiate()
	currentNode.find_child("Content").add_child(video)
	Global.currentStreamer=currentStreamer#so that implementing reactions is easier
	Global.streamerIndices.append(currentStreamerIndex)

func _process(_delta: float) -> void:
	$UI/TrackIndicatorWrong.scale.y = $TrackPlaybackHandler.fade
	$UI/TrackIndicatorRight.scale.y = 1.0-$TrackPlaybackHandler.fade
	

	
func _on_eol_stop_spawning_arrows_timer_timeout() -> void:
	midiPlayerArrows.playing=false
	
func _on_switch_scene_timer_timeout() -> void:
	Global.currentStreamIndex += 1
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")
	
func nextArrowTact():
	midiPlayerArrows.play()
	
func _on_midi_player_arrows_finished() -> void:
	counterForArrowsPlayer+=1
	if counterForArrowsPlayer<Global.musicTracks[index].size():
		midiPlayerArrows.set_file(Global.musicTracks[index][counterForArrowsPlayer])
	else:
		Global.stopMetronomeArrows()


func _on_track_playback_handler_layer_finished() -> void:
	$TrackPlaybackHandler.stop()
	for trackPlayer in trackPlayers:
		trackPlayer.stop()
	switchSceneTimer.start()
	Global.inputRecorder.stopRecording()
	Global.stopMetronome()

func _on_start_spawning_arrows_timer_timeout() -> void:
	Global.startMetronomeArrows()
	$StartPlayingMusicTimer.start()
