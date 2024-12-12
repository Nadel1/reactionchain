extends Node

enum Events {PAUSE_REWIND} #Potentially add more events later
var eventChances = [0.5]
var eventsHad = 0 #TODO: Only have 1 of these per stream
#TODO: Record events

func generateEvents():
	var insertAt = randi_range(1,Global.musicTracks.size()-1)
	#TODO: Variable chance of event happening in the first place
	get_parent().insertEvent(insertAt)
