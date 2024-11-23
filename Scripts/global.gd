extends Node

# Any stuff that needs to be accessible from anywhere and/or persistent
# between scene changes goes in here


var inputHandler : InputHandler
var inputRecorder : InputRecorder
var recordingsMovement = []
var recordingsReaction= []
var currentStreamIndex = 0
var score = 0
var streamerIndices =[]
var currentStreamer=null
var musicTracks=[]
