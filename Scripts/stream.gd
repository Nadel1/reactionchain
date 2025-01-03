extends Node2D

@onready var midiPlayerArrows=$MidiPlayerArrows
@onready var startPlayingMusicTimer=$StartPlayingMusicTimer
@onready var switchSceneTimer=$SwitchSceneTimer
@onready var inputRecorder=$InputRecorder
var recording = preload("res://Scenes/Stream/recording.tscn")
var startVideo = preload("res://Scenes/Stream/startVideo.tscn")
const RECORDEDCHAT=preload("res://Scenes/Objects/ChatRecorded.tscn")
var gameOverPossible=true#modified by developermode
const DONATION=preload("res://Scenes/Objects/Donations/donation.tscn")

#preload streamers
const STREAMER0=preload("res://Scenes/Objects/Streamers/streamerBasic0.tscn")
const STREAMER1=preload("res://Scenes/Objects/Streamers/streamerBasic1.tscn")
const STREAMER2=preload("res://Scenes/Objects/Streamers/streamerBasic2.tscn")
var allStreamers=[STREAMER0, STREAMER1, STREAMER2]
var currentStreamerIndex=0
var currentStreamer=null
var donationsThresholdViewer=200#only once this threshold is reached will donations appear


var counterForArrowsPlayer=0#counter which index from musicToPlay should be inserted next
var index

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

func prepareArrows():
	var firstSnippet = Global.musicTracks[index][0].getLayer(index)
	midiPlayerArrows.set_file(firstSnippet)
	midiPlayerArrows.play_speed = Global.playbackSpeed
	
	
func _ready():
	$UI/Money/Text.text= "Money: "+str(Global.moneyEarned)
	$UI/TrackIndicatorWrong.visible=Global.developerMode
	$UI/TrackIndicatorRight.visible=Global.developerMode
	index=Global.currentStreamIndex
	Global.tactArrows.connect(nextArrowTact)
	$MidiPlayerBass.setName("Bass")
	$MidiPlayerBass.play_speed = Global.playbackSpeed
	Global.tact.connect($MidiPlayerBass.play)
	
	AudioTrackProvider.prepareMusic()
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

	if index > 0:
		for i in range(0,index):
			var recursionInstance = recording.instantiate()
			var lastStreamer=allStreamers[Global.streamerIndices[index-1-i]].instantiate()
			lastStreamer.position=$UI/StreamerPlaceholder.position
			lastStreamer.scale=$UI/StreamerPlaceholder.scale
			lastStreamer.init(Global.streamerIndices[Global.currentStreamIndex-1-i], Global.currentStreamIndex-1-i)
			recursionInstance.setStreamer(lastStreamer)
			recursionInstance.add_child(lastStreamer)
			recursionInstance.setIndex((index-1)-i)
			currentNode.find_child("Content").add_child(recursionInstance)
			recursionInstance.find_child("VideoFrame").init((Global.currentStreamIndex-1)-i)
			var trackPlayer = recursionInstance.find_child("TrackPlaybackHandler")
			if trackPlayer != null:
				trackPlayers.append(trackPlayer)
				trackPlayer.find_child("MidiPlayerCorrect").bus = "Correct"+str((index-1)-i)
				trackPlayer.find_child("MidiPlayerFail").bus = "Fail"+str((index-1)-i)
			currentNode = recursionInstance
	var video = startVideo.instantiate()
	currentNode.find_child("Content").add_child(video)
	Global.currentStreamer=currentStreamer#so that implementing reactions is easier
	Global.streamerIndices.append(currentStreamerIndex)

func _process(_delta: float) -> void:
	$UI/TrackIndicatorWrong.scale.y = $TrackPlaybackHandler.fade
	$UI/TrackIndicatorRight.scale.y = 1.0-$TrackPlaybackHandler.fade
	if Global.score>=donationsThresholdViewer and Global.score>= Global.nextDonationViewerCount and Global.donationOnScreen==false:
		Global.nextDonationViewerCount+=Global.viewersNeededToNextDonation
		var newDonation=DONATION.instantiate()
		newDonation.position=$UI/DonationPlaceholder.position
		newDonation.loadDonation(Global.difficultyDonations)
		find_child("UI").add_child(newDonation)
	

	
func _on_eol_stop_spawning_arrows_timer_timeout() -> void:
	midiPlayerArrows.playing=false
	
func _on_switch_scene_timer_timeout() -> void:
	Global.currentStreamIndex += 1
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")
	
func nextArrowTact():
	if counterForArrowsPlayer<Global.musicTracks[index].size():
		midiPlayerArrows.set_file(Global.musicTracks[index][counterForArrowsPlayer].getLayer(index))
		midiPlayerArrows.play()
	else:
		Global.stopMetronomeArrows()
	counterForArrowsPlayer+=1

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
