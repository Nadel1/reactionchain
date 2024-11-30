extends Node
class_name TrackPlaybackHandler

@onready var playerCorrect = $MidiPlayerCorrect
@onready var playerFail = $MidiPlayerFail
var layerIndex = 0
var fade = 0.0
var inputFadeTime = 1.0
var fullVolume = -20.0
var zeroVolume = -40.0
var snippetIndex = 0
var audible = true
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
	playerCorrect.play()
	playerFail.set_volume_db(zeroVolume)
	playerFail.play()

func stop():
	playerCorrect.playing = false
	playerFail.playing = false

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

func nextTact():
	playerCorrect.play()
	playerFail.play()

func _on_midi_player_correct_finished() -> void:
	snippetIndex += 1
	if snippetIndex<Global.musicTracks[layerIndex].size():
		playerCorrect.set_file(Global.musicTracks[layerIndex][snippetIndex].getLayer(layerIndex))
		playerFail.set_file(playerCorrect.file)
	else:
		#end of layer
		layerFinished.emit()
