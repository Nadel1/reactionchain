extends Node

# Any stuff that needs to be accessible from anywhere and/or persistent
# between scene changes goes in here


var inputHandler : InputHandler
var recordings = []
var currentStreamIndex = 0
var score = 0
var streamerIndices =[]
var currentStreamer=null
var reactions:Array[ReactionRecord]=[]#holds reactionRecords for each streamer
