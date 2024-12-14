extends Node

var eventChances = [0.5]

func generateEvents():
	var newEvent = Event.new()
	var length = randi_range(2,4)
	var insertAt = randi_range(1,Global.musicTracks[0].size()-(length + 1))
	if(insertAt < 1):
		print("Event could not be generated")
		return
	newEvent.length = length
	newEvent.type = Event.Types.PAUSE_REWIND
	newEvent.startIndex = insertAt
	newEvent.startLayer = Global.currentStreamIndex
	
	#TODO: Variable chance of event happening in the first place
	scheduleEvent(newEvent)

func scheduleEvent(newEvent : Event):
	get_parent().insertEvent(newEvent)
