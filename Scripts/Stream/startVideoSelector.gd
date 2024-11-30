extends Node

@export_file("*.ogv") var files : Array[String]

func _ready() -> void:
	var index = rand_from_seed(Global.mainSeed)[0] % files.size()
	$VideoStreamPlayer.stream.set_file(files[index])
	$VideoStreamPlayer.play()
	
