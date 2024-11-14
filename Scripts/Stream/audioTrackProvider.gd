extends Node
class_name AudioTrackProvider

@export_file("*.MID") var tracks : Array[String]
@export_file("*.sf2") var soundfonts : Array[String]

func getTrack(index : int):
	if checkIndex(index):
		return tracks[index]
	return null

func getSoundFont(index : int):
	if checkIndex(index):
		return soundfonts[index]
	return null

func checkIndex(index : int) -> bool:
	return index < len(tracks) and index >= 0
