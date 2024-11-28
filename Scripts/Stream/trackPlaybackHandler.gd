extends Node
class_name TrackPlaybackHandler

@onready var playerCorrect = $MidiPlayerCorrect
@onready var playerFail = $MidiPlayerFail
var index = 0
var fade = 0.0
var inputFadeTime = 1.0
var counterForMusicPlayer=0#counter which index from musicToPlay should be inserted next
signal layerFinished

func setIndex(index : int):
	self.index = index
	call_deferred("setupPlayers")

func _ready() -> void:
	Global.tact.connect(nextTact)
	
func setTrack(snippet):
	playerCorrect.set_file(snippet)
	playerFail.set_file(snippet)
	
func setupPlayers():
	playerCorrect.setName("Correct"+str(index))
	playerFail.setName("Fail"+str(index))
	var musicCorrect = Global.musicTracks[index][0]
	var instrument = $AudioTrackProvider.getSoundFont(index)
	if musicCorrect != null:
		playerCorrect.set_soundfont(instrument)
		playerCorrect.set_file(musicCorrect)
		playerFail.set_file(musicCorrect)
		playerFail.set_soundfont(instrument)
		playerFail.key_shift = -1
	playerCorrect.playing = false
	playerFail.playing = false


func start():
	playerCorrect.play()
	playerFail.set_volume_db(-80)
	playerFail.play()

func stop():
	playerCorrect.playing = false
	playerFail.playing = false

func getTrackCorrect():
	return playerCorrect.file

func failInput():
	playerCorrect.set_volume_db(-80)
	playerFail.set_volume_db(-20)
	$FailFade.start(inputFadeTime)
	pass

func failReaction(length:float):
	$FailFade.start(length)
	pass

func _process(delta: float) -> void:
	var factor = $FailFade.time_left/$FailFade.wait_time
	playerCorrect.set_volume_db(lerpf(-20,-40, factor))
	playerFail.set_volume_db(lerpf(-40,-20, factor))
	fade = factor

func nextTact():
	playerCorrect.play()
	playerFail.play()

func _on_midi_player_correct_finished() -> void:
	counterForMusicPlayer+=1
	if counterForMusicPlayer<Global.musicTracks[index].size():
		playerCorrect.set_file(Global.musicTracks[index][counterForMusicPlayer])
		playerFail.set_file(Global.musicTracks[index][counterForMusicPlayer])
	else:
		#end of layer
		self.emit_signal("layerFinished")
