extends Node

@export var funkiness = 0
var A = true

signal menuTact(int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Metronome.wait_time = Global.snippetLength
	$Metronome.start()
	menuTact.connect($BackingTrack.tact)
	$Chords0.setName("MenuChords0")
	$Chords1.setName("MenuChords1")
	_on_metronome_timeout()

func _on_metronome_timeout() -> void:
	var snippet = AudioTrackProvider.getSnippet(A)
	if funkiness > 0:
		$Chords0.file = snippet.getLayer(3)
		$Chords1.file = snippet.getLayer(2)
		$Chords0.play()
		$Chords1.play()
	A = !A
	menuTact.emit(0)
