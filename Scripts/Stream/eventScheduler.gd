extends Node

var eventChances = 2 # Chance is "1 in [eventChances]"
var eventLengths = [2,4]

var actualMusicLengths = []

func generateEvents():
	actualMusicLengths.push_back(Global.musicTracks.back().size())
	if Global.currentStreamIndex>0 and Global.score>200:
		var coinflip = randi() % eventChances == 0
		if coinflip:
			var newEvent = Event.new()
			var length = eventLengths.pick_random()
			# TODO: Find out why this breaks at 1 and 2
			var insertAt = randi_range(3,Global.musicTracks[0].size()-1)
			newEvent.length = length
			newEvent.type = Event.Types.PAUSE_REWIND
			newEvent.startIndex = insertAt
			newEvent.startLayer = Global.currentStreamIndex
			
			#TODO: Variable chance of event happening in the first place
			scheduleEvent(newEvent)

func scheduleEvent(newEvent : Event):
	get_parent().insertEvent(newEvent)
