extends Node

@export var Asnippets : Array[TrackSnippet]
@export var Bsnippets : Array[TrackSnippet]
@export_file("*.sf2") var soundfonts : Array[String]

# first entry is the current layer, earlier layers without a corresponding entry are silent.
# in dB, -20 is the default volume, -40 is silent
@export var layerVolumes = [-20, -25, -30]

func getSnippet(A = true):
	return Asnippets.pick_random() if A else Bsnippets.pick_random()

func getSoundFont(layerIndex : int):
	return soundfonts[min(layerIndex, soundfonts.size() - 1)]

func prepareMusic():
	var track = []
	var A = true
	if Global.currentStreamIndex > 0:
		for i in Global.musicTracks[0].size():
			if Global.packetToBeDropped[i]:
				track.append(Asnippets.pick_random() if A else Bsnippets.pick_random())
			else:
				track.append(Global.musicTracks[Global.currentStreamIndex-1][i])
			Global.packetToBeDropped[i] = false
			A = !A
	else:
		for i in Global.lengthOfMusic:
			track.append(Asnippets.pick_random() if A else Bsnippets.pick_random())
			Global.packetToBeDropped.append(false)
			A = !A
	
	Global.musicTracks.append(track)
	#print("Created track with length " + str(track.size()))
	$EventScheduler.generateEvents()

func insertEvent(newEvent : Event): #TODO: Add type parameter
	Global.insertEvent(newEvent)
	var A = Global.musicTracks[0][newEvent.startIndex].type == TrackSnippet.SnippetType.A
	#TODO: add solo-specific snippets only
	for i in range(0,newEvent.length):
		Global.packetToBeDropped.append(false)
		for j in Global.musicTracks.size():
			Global.musicTracks[j].insert(newEvent.startIndex+i, Asnippets.pick_random() if A else Bsnippets.pick_random())
		for j in Global.recordingsReaction.size():
			Global.recordingsReaction[j].insert(newEvent.startIndex+i, -1)
		A = !A
	#print(" -> Extended to " + str(Global.musicTracks.back().size()))
	pass
