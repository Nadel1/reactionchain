extends Node

@export var snippets : Array[TrackSnippet]
@export_file("*.sf2") var soundfonts : Array[String]

func getSnippet(index : int):
	return snippets[index % snippets.size()]

func getSoundFont(layerIndex : int):
	return soundfonts[layerIndex % soundfonts.size()]

func prepareMusic():
	var track = []
	if Global.currentStreamIndex > 0:
		for i in Global.lengthOfMusic:
			if Global.packetToBeDropped[i]:
				track.append(snippets.pick_random())
			else:
				track.append(Global.musicTracks[Global.currentStreamIndex-1][i])
			Global.packetToBeDropped[i] = false
	else:
		for i in Global.lengthOfMusic:
			track.append(snippets.pick_random())
			Global.packetToBeDropped.append(false)
	
	Global.musicTracks.append(track)
