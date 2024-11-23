extends Node
class_name AudioTrackProvider

@export_file("*.MID") var tracksCorrect : Array[String]
@export_file("*.MID") var tracksFail : Array[String]
@export_file("*.sf2") var soundfonts : Array[String]

func getTrackCorrect(index : int):
	if checkIndex(index):
		return tracksCorrect[index]
	return null

func getTrackFail(index : int):
	if checkIndex(index):
		return tracksFail[index]
	return null

func getSoundFont(index : int):
	if checkIndex(index):
		return soundfonts[index]
	return null

func checkIndex(index : int) -> bool:
	return index < len(tracksCorrect) and index >= 0
