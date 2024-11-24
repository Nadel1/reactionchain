extends Node

# Any stuff that needs to be accessible from anywhere and/or persistent
# between scene changes goes in here


var inputHandler : InputHandler
var inputRecorder : InputRecorder
var recordingsMovement = []
var recordingsReaction = []
var recordingsFails = []
var currentTrackHandler : TrackPlaybackHandler
var currentStreamIndex = 0
var score = 0
var streamerIndices =[]
var currentStreamer=null
var difficulty = 1 # 1: arrow on every note, 4: arrow on every 4th note, etc
var musicTracks=[]
var packetsToBeDropped=[]

#generate music track
#file path (preload doesnt work apparently with mid files)
const LAYER1="res://Assets/Audio/Tracks/snippets/lead1_layer1.MID"
const LAYER2="res://Assets/Audio/Tracks/snippets/lead1_layer2.MID"
const LAYER3="res://Assets/Audio/Tracks/snippets/lead1_layer3.MID"

var allSnippetsLayer1=[LAYER1]
var allSnippetsLayer2=[LAYER2]
var allSnippetsLayer3=[LAYER3]

var allLayers=[allSnippetsLayer1,allSnippetsLayer2,allSnippetsLayer3]
var musicToPlay=[]
@export var lengthOfMusic=5#number of reaction packets to play
var dropPacketsIndex=0

func prepareMusic():
	var layerToChoseFrom= allLayers[Global.currentStreamIndex%allLayers.size()]#modulo only needed here for endless 
	if Global.currentStreamIndex==0:
		for i in lengthOfMusic:
			musicToPlay.append(layerToChoseFrom.pick_random())
	else:
		#play the corresponding next layer to the previous snippet or drop if needed
		for i in lengthOfMusic:
			var lastReactionPacket=Global.musicTracks[Global.currentStreamIndex%allLayers.size()-1][i]
			var lastIndex=allLayers[Global.currentStreamIndex%allLayers.size()-1].find(lastReactionPacket)
			print("last index: ", lastIndex)
			
			if Global.packetsToBeDropped.size()==0:
				musicToPlay.append(layerToChoseFrom[lastIndex])
			elif Global.packetsToBeDropped[dropPacketsIndex]==lastIndex:
				print("append different ")
				musicToPlay.append(layerToChoseFrom.pick_random())
				
	Global.musicTracks.append(musicToPlay)
	
