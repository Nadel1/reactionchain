extends Node
class_name TrackPlaybackHandler

@onready var playerCorrect = $MidiPlayerCorrect
@onready var playerFail = $MidiPlayerFail
var layerIndex = 0
var fade = 0.0
var inputFadeTime = 1.0
var fullVolume = -20.0
var zeroVolume = -40.0
var audible = true
var playingIndex = -1 # Mirrors Global.musicSnippetIndex but always gives the snippet being played right now
signal layerFinished

func setIndex(id : int):
	layerIndex = id
	fullVolume = -20.0 - 5*(Global.currentStreamIndex - id)
	if fullVolume <= zeroVolume: audible = false
	call_deferred("setupPlayers")

func _ready() -> void:
	Global.tact.connect(nextTact)
	
func setTrack(snippet):
	playerCorrect.set_file(snippet)
	playerFail.set_file(snippet)
	
func setupPlayers():
	playerCorrect.setName("Correct"+str(layerIndex))
	playerFail.setName("Fail"+str(layerIndex))
	var snippet = Global.musicTracks[layerIndex][0].getLayer(layerIndex)
	var instrument = AudioTrackProvider.getSoundFont(layerIndex)
	if snippet != null:
		playerCorrect.set_soundfont(instrument)
		playerCorrect.set_file(snippet)
		playerFail.set_file(snippet)
		playerFail.set_soundfont(instrument)
		playerFail.key_shift = -1
	playerCorrect.playing = false
	playerFail.playing = false
	playerCorrect.call_deferred("set_volume_db", fullVolume)


func start():
	playerCorrect.play_speed = Global.playbackSpeed
	playerCorrect.play()
	playerFail.play_speed = Global.playbackSpeed
	playerFail.set_volume_db(zeroVolume)
	playerFail.play()

func stop():
	playerCorrect.playing = false
	playerFail.playing = false

func pause():
	stop()

func resume():
	playerCorrect.playing = true
	playerFail.playing = true

func getTrackCorrect():
	return playerCorrect.file

func failInput():
	playerCorrect.set_volume_db(zeroVolume)
	playerFail.set_volume_db(fullVolume)
	$FailFade.start(inputFadeTime)
	pass

func failReaction(length:float):
	$FailFade.start(length)
	pass

func _process(_delta: float) -> void:
	var factor = $FailFade.time_left/$FailFade.wait_time
	playerCorrect.set_volume_db(lerpf(fullVolume, zeroVolume, factor))
	playerFail.set_volume_db(lerpf(zeroVolume, fullVolume, factor))
	fade = factor

func nextTact(snippetIndex):
	if snippetIndex<Global.musicTracks[layerIndex].size():
		playingIndex = snippetIndex
		playerCorrect.set_file(Global.musicTracks[layerIndex][playingIndex].getLayer(layerIndex))
		playerFail.set_file(playerCorrect.file)
		playerCorrect.play()
		playerFail.play()
	else:
		#end of layer
		layerFinished.emit()
	updatePlayingState()

func skipSnippet():
	updatePlayingState()

func updatePlayingState():
	if Global.pauseDepths.size() > 0 and Global.pauseDepths.back() > layerIndex:
		playerCorrect.playing = false
		playerFail.playing = false
