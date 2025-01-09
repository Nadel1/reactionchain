extends Node2D

@onready var messageTimer=$MessageTimer
@onready var reactionTimer=$ReactionTimer
@onready var chatText=$ChatBackground/RichTextLabel
var timerCounter=0
var probabilityNextMessage=0.5
var lastScore=0#to have a relation between viewer counts and active commenters
var usernameStrings=["new","user","destroyer","bob","spencer","dark","hunter","ree","wompwomp","myname"]
var messagesString=["why the hate?","haha nice one","i love it when you do that","im your biggest fan!","notice me!","good video"]
var welcomeStrings=["hi","hey","hewwo","how are you","wazzup","o/"]
var pogReactionStrings=["poooooooooooog","pog","poggies","poggers","woah!"]
var laughReactionStrings=["xD","hahaha","KEKW","LUL"]
var cringeReactionStrings=["cringe","ew","HUH","what"]
var angryReactionStrings=["boo!","wtf","wtf am i seeing","turn that off"]
var colors=["red","blue","green","yellow","violet","pink","darkgreen","orange"]
var reactionMessagesCount=0
var currentReactionMessage=0
var reactionMessageType=RT.Emotion.NONE
var numMessages = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chatText.text=""

func appendAndTruncate(newMessage):
	numMessages += 1
	chatText.text=chatText.text+newMessage
	if numMessages > 6:
		var firstNewline = chatText.text.find("\n")
		chatText.text = chatText.text.substr(firstNewline + 1)
	

func generateMessage(user,firstMessage=false):
	var msg
	if firstMessage:
		msg=welcomeStrings.pick_random()
	else:
		msg=messagesString.pick_random()
	var newMessage="[color="+user[1]+"]"+user[0]+"[/color]:" +msg+"\n"
	appendAndTruncate(newMessage)
	return newMessage
	
	
func generateNewUser():
	var newUserName=usernameStrings.pick_random()+usernameStrings.pick_random()+str(randi()%70)
	var newUser=[newUserName,colors.pick_random()]
	Global.chatUsers.append(newUser)
	return newUser

func deleteUsers():
	pass
	
#background fluff
func sendNewMessage():
	var message
	if Global.chatUsers.size()<10 or Global.chatUsers.size()==0:#generate new user if the viewer count has doubled
		lastScore=Global.score
		message=generateMessage(generateNewUser(),true)#new users introduce themselves
	else:
		message=generateMessage(Global.chatUsers.pick_random())
	Global.inputRecorder.appendChatMessage(message)
		
	var waittime=max(1,10-int(Global.score)/50)
	print("wait time: ", waittime)
	messageTimer.start(waittime)
	

func sendReactionMessage():
	#if Global.performanceMode: return
	if currentReactionMessage>reactionMessagesCount:
		return
	if Global.chatUsers.size()==0:
		generateNewUser()
	var user=Global.chatUsers.pick_random()
	var msg=""
	match reactionMessageType:
		RT.Emotion.POG:
			msg=pogReactionStrings.pick_random()
		RT.Emotion.CRINGE:
			msg=cringeReactionStrings.pick_random()
		RT.Emotion.LAUGH:
			msg=laughReactionStrings.pick_random()
		RT.Emotion.ANGRY:
			msg=angryReactionStrings.pick_random()
	var newMessage="[color="+user[1]+"]"+user[0]+"[/color]:" +msg+"\n"
	Global.inputRecorder.appendChatMessage(newMessage)
	appendAndTruncate(newMessage)
	currentReactionMessage+=1
	reactionTimer.start()
	
	
#messages that pop up specifically when reaction occurs/reacting to reaction
func initiateSendReactionMessage(reaction:RT.Emotion):
	var minimumMessages=randi()%10+2
	reactionMessagesCount=min(minimumMessages,Global.score/10)
	currentReactionMessage=0
	reactionMessageType=reaction
	sendReactionMessage()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Global.chatLog.size()>Global.currentStreamIndex:
		#replay 
		pass
	else: 
		if Global.score>=lastScore*2:#score has doubled, more chat users
			lastScore=Global.score
		elif Global.score<=lastScore/2:#score has halved, less chat users
			lastScore=Global.score
			deleteUsers()

func _on_timer_since_last_reaction_message_timeout() -> void:
	sendReactionMessage()


func _on_message_timer_timeout() -> void:
	sendNewMessage()
