extends Node2D

@onready var chatText=$ChatBackground/ChatText
var numMessages = 0
var off = false

func _ready() -> void:
	chatText.text=""

func appendAndTruncate(newMessage):
	numMessages += 1
	chatText.text=chatText.text+newMessage
	if numMessages > 6:
		var firstNewline = chatText.text.find("\n")
		chatText.text = chatText.text.substr(firstNewline + 1)
