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
const STREAMER0=preload("res://Scenes/Objects/Streamers/streamerBasic0.tscn")
const STREAMER1=preload("res://Scenes/Objects/Streamers/streamerBasic1.tscn")
const STREAMER2=preload("res://Scenes/Objects/Streamers/streamerBasic2.tscn")
var allStreamers=[STREAMER1,STREAMER2]
var currentStreamerIndex=0
var currentStreamer=null

#generate music track
#file path (preload doesnt work apparently with mid files)
const LAYER1="res://Assets/Audio/Tracks/snippets/lead1_layer1.MID"
const LAYER2="res://Assets/Audio/Tracks/snippets/lead1_layer2.MID"
const LAYER3="res://Assets/Audio/Tracks/snippets/lead1_layer3.MID"

var allSnippetsLayer1=[LAYER1]
var allSnippetsLayer2=[LAYER2]
var allSnippetsLayer3=[LAYER3]

var allLayers=[allSnippetsLayer1,allSnippetsLayer2,allSnippetsLayer3]
var musicToPlay=[]
@export var lengthOfMusic=5#number of reaction packets to play
var counterForArrowsPlayer=0#counter which index from musicToPlay should be inserted next
var counterForMusicPlayer=0#counter which index from musicToPlay should be inserted next
var dropPacketsIndex=0

@export var musicDelay=6
var midiPlayers : Array[MidiPlayer]

func _on_start_playing_music_timer_timeout() -> void:
	midiPlayerMusic.playing=true
	midiPlayerMusic.play()
	for player in midiPlayers:
		player.play()

func prepareStreamer():
	if Global.streamerIndices.size()>0 and currentStreamerIndex==Global.streamerIndices[Global.currentStreamIndex-1]: #making sure we dont pick the same streamer twice in a row
		if currentStreamerIndex==allStreamers.size()-1:
			currentStreamer=allStreamers[0]
		else:
			currentStreamer=allStreamers[currentStreamerIndex+1]
		currentStreamerIndex=allStreamers.find(currentStreamer)
		
	currentStreamer=allStreamers[currentStreamerIndex].instantiate()
	currentStreamer.position=Vector2(922,414)
	currentStreamer.scale=Vector2(4,4)
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
			var lastReactionPacket=Global.musicTracks[Global.currentStreamIndex-1][i]
			var lastIndex=allLayers[Global.currentStreamIndex-1].find(lastReactionPacket)
			print("last index: ", lastIndex)
			
			if Global.packetsToBeDropped.size()==0:
				musicToPlay.append(layerToChoseFrom[lastIndex])
			elif Global.packetsToBeDropped[dropPacketsIndex]==lastIndex:
				print("append different ")
				musicToPlay.append(layerToChoseFrom.pick_random())
				
	Global.musicTracks.append(musicToPlay)
	midiPlayerMusic.set_file(musicToPlay[0])
	midiPlayerArrows.set_file(musicToPlay[0])
	var instrument = $AudioTrackProvider.getSoundFont(Global.currentStreamIndex)#maybe also chose random soundfont?
	midiPlayerMusic.set_soundfont(instrument)
	midiPlayerArrows.play()

		
func _ready():
	prepareStreamer()
	startPlayingMusicTimer.set_wait_time(musicDelay)
	updateScore()
	prepareMusic()
	var audioFile = $AudioTrackProvider.getTrack(Global.currentStreamIndex)

	var currentNode = $UI/VideoFrame
	if Global.currentStreamIndex > 0:
		for i in range(0,Global.currentStreamIndex):
			var recursionInstance = recording.instantiate()
			var lastStreamer=allStreamers[Global.streamerIndices[Global.currentStreamIndex-1-i]].instantiate()
			lastStreamer.position=Vector2(922,414)
			lastStreamer.scale=Vector2(4,4)
			recursionInstance.setStreamer(lastStreamer)
			recursionInstance.add_child(lastStreamer)
			recursionInstance.setIndex((Global.currentStreamIndex-1)-i)
			currentNode.find_child("Content").add_child(recursionInstance)
			var midiPlayer = recursionInstance.find_child("MidiPlayer")
			if midiPlayer != null:
				midiPlayers.append(midiPlayer)
			currentNode = recursionInstance
	var video = startVideo.instantiate()
	currentNode.find_child("Content").add_child(video)
	$Transition.play("zoomOut")
	Global.currentStreamer=currentStreamer#so that implementing reactions is easier
	Global.streamerIndices.append(currentStreamerIndex)
	
func updateScore():
	scoreLabel.text="Score: "+str(Global.score)
	
	
func _on_eol_stop_playing_music_timer_timeout() -> void:
	midiPlayerMusic.playing=false
	for player in midiPlayers:
		player.playing = false
	switchSceneTimer.start()
	
func _on_switch_scene_timer_timeout() -> void:
	Global.currentStreamIndex += 1
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")


func _on_midi_player_arrows_finished() -> void:
	counterForArrowsPlayer+=1
	if counterForArrowsPlayer<lengthOfMusic:
		midiPlayerArrows.set_file(musicToPlay[counterForArrowsPlayer])
		midiPlayerArrows.play()
		

func _on_midi_player_music_finished() -> void:
	counterForMusicPlayer+=1
	if counterForMusicPlayer<lengthOfMusic:
		midiPlayerMusic.set_file(musicToPlay[counterForMusicPlayer])
		midiPlayerMusic.play()
	else:
		#end of layer
		switchSceneTimer.start()
