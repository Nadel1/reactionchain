extends Node2D

@onready var midiPlayerArrows=$MidiPlayerArrows
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
const STREAMERAI=preload("res://Scenes/Objects/Streamers/streamerAI.tscn")
const STREAMERCATEARS=preload("res://Scenes/Objects/Streamers/streamerCatEars.tscn")
const STREAMERSERVER=preload("res://Scenes/Objects/Streamers/streamerServer.tscn")
var allStreamers=[STREAMERCATEARS,STREAMER0, STREAMER1, STREAMER2, STREAMERAI,STREAMERSERVER]

var currentStreamerIndex=0
var currentStreamer=null

var index
var arrowPlayingIndex = -1

var trackPlayers : Array[TrackPlaybackHandler]

func _on_start_playing_music_timer_timeout() -> void:
	$TrackPlaybackHandler.call_deferred("start")
	for player in trackPlayers:
		player.call_deferred("start")
	

func prepareStreamer():
	if Global.currentStreamIndex<3:
		currentStreamerIndex=randi()%2
	elif Global.currentStreamIndex< 6:
		currentStreamerIndex=randi()%2+2
	else:
		currentStreamerIndex=randi()%2+4
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
	Global.donationOnScreen=false
	$UI/Money/Text.text= "Money: "+str(Global.displayedMoney)
	$UI/TrackIndicatorWrong.visible=Global.developerMode
	$UI/TrackIndicatorRight.visible=Global.developerMode
	index=Global.currentStreamIndex
	Global.tactArrows.connect(nextArrowTact)
	Global.pause.connect(pause)
	Global.resume.connect(resume)
	Global.debugWindow = $UI/DebugWindow/DebugLabel
	$UI/DebugWindow.visible = Global.developerMode
	Global.resetPerStream()
	Global.arrowTravelDelay.timeout.connect(_on_start_playing_music_timer_timeout)
	
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
		$UI/ArrowKeys.visible = false
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
	if Global.score>= Global.nextDonationViewerCount and Global.donationOnScreen==false:
		Global.nextDonationViewerCount+=Global.viewersNeededToNextDonation
		var newDonation=DONATION.instantiate()
		newDonation.position=$UI/DonationPlaceholder.position
		newDonation.loadDonation(Global.difficultyDonations)
		find_child("UI").add_child(newDonation)
	
func _on_switch_scene_timer_timeout() -> void:
	Global.currentStreamIndex += 1
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")
	
func nextArrowTact(snippetIndex):
	if snippetIndex<Global.musicTracks[index].size():
		arrowPlayingIndex = snippetIndex
		midiPlayerArrows.set_file(Global.musicTracks[index][arrowPlayingIndex].getLayer(index))
		midiPlayerArrows.play()
	else:
		Global.stopMetronomeArrows()
	updateArrowPlayingState()

func updateArrowPlayingState():
	#if Global.pauseDepths.size() > 0 and Global.pauseDepths.back() >= index:
	#	midiPlayerArrows.playing = false
	pass

func pause(_depth):
	pass
	
func resume(_depth):
	pass

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
