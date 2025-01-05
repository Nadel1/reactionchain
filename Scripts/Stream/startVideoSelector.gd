extends Node

@export_file("*.ogv") var files : Array[String]

func _ready() -> void:
	var index = rand_from_seed(Global.mainSeed)[0] % files.size()
	$VideoStreamPlayer.stream.set_file(files[index])
	$VideoStreamPlayer.play()
	Global.pause.connect(pause)
	Global.resume.connect(resume)

func pause(_depth : int):
	$VideoStreamPlayer.set_paused(true)
	
func resume(_depth : int):
	$VideoStreamPlayer.set_paused(Global.pauseDepths.size() > 0)
