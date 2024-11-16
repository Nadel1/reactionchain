extends Node
class_name TrackPlaybackHandler

@onready var playerCorrect = $MidiPlayerCorrect
@onready var playerFail = $MidiPlayerFail
@export var failFalloff : Curve
var index = 0

func setIndex(index : int):
	self.index = index
	call_deferred("setupPlayers")

func setupPlayers():
	var musicCorrect = $AudioTrackProvider.getTrackCorrect(index)
	var musicFail = $AudioTrackProvider.getTrackFail(index)
	var instrument = $AudioTrackProvider.getSoundFont(index)
	if musicCorrect != null:
		playerCorrect.set_file(musicCorrect)
		playerCorrect.set_soundfont(instrument)
		playerFail.set_file(musicFail)
		playerFail.set_soundfont(instrument)

func start():
	playerCorrect.play()
	#playerFail.set_volume_db(-80)
	playerFail.play()

func stop():
	playerCorrect.stop()
	playerFail.stop()

func getTrackCorrect():
	return playerCorrect.file

func failInput():
	#playerCorrect.set_volume_db(-80)
	#playerFail.set_volume_db(-20)
	$FailFade.start()

func _process(delta: float) -> void:
	var factor = $FailFade.time_left/$FailFade.wait_time
	#playerCorrect.set_volume_db(lerpf(-20,-80, factor))
	#playerFail.set_volume_db(lerpf(-80,-20, factor))
