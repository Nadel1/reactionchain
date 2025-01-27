extends Node2D

var names:Array[String]
var scores:Array[int]

@onready var nameValues=$MarginContainer/VBoxContainer/GridContainer/NameValues
@onready var scoreValues=$MarginContainer/VBoxContainer/GridContainer/ScoreValues
@onready var lineEditContainer= $MarginContainer/VBoxContainer/HBoxContainerLineEdit
@onready var networkHandler=$NetworkHandler
@onready var onlineIndicator=$OnlineIndicator
@export var onlineMode=false

const FILE_PATH="scores.save"

signal scoreBoardAvailable
func _ready() -> void:
	networkHandler.offline.connect(updateAvailability)
	networkHandler.scoreboardAvailable.connect(loadScores)

func debug():
	print("display scores")
func updateAvailability():
	onlineIndicator.play("offline")

func showLineEdit():
	#print("level is: ", get_tree().get_root().name)
	if get_parent()!=null and get_parent().name=="MainMenu":
		return  
	if Global.overallScore>scores[scores.size()-1] or scores.size()<10:
		lineEditContainer.show()
	else:
		lineEditContainer.hide()

func sort():
	var scoresSorted:Array[int]
	scoresSorted=scores.duplicate()
	scoresSorted.sort_custom(func(a,b):return a>b)
	var namesSorted=names.duplicate()
	var newIndex=0
	for i in range(scores.size()):
		newIndex=scoresSorted.find(scores[i])
		namesSorted[newIndex]=names[i]
	names=namesSorted
	scores=scoresSorted
	

func updateScoreboard():
	sort()
	nameValues.text=""
	scoreValues.text=""
	for i in range(min(names.size(),10)):
		var fillString=" "
		for j in range(11-names[i].length()):
			fillString+=" "
		var nameFilled=names[i]+fillString
		if i>=9:
			nameValues.text+="> #"+str(i+1)+" "+names[i]+'\n'
		else:	
			nameValues.text+="> #"+str(i+1)+"  "+names[i]+'\n'
		scoreValues.text+= str(scores[i])+'\n'

func checkHighScore(potentialHighScore:int):
	if potentialHighScore>=scores[0]:
		return true
	else:
		return false
	
func checkValidity(input:String):
	if input.contains("!")or  input.contains("?") or  input.contains("\n"):
		return false
	else:
		return true
		
func addEntry(name:String,score:int):
	names.append(name)
	scores.append(score)
	updateScoreboard()
	
	
func saveScores():
	if onlineMode:
		var sendScoreboard=""
		for i in range(names.size()):
			sendScoreboard+=names[i]+","+str(scores[i])+"\n"
		print("sending scoreboard from scoreboard save score")
		networkHandler.sendNewHighscore(sendScoreboard)
	else:
		var file= FileAccess.open(FILE_PATH, FileAccess.READ_WRITE)
		for i in range(names.size()):
			file.store_line(names[i]+","+str(scores[i]))
		file.close()
	
func loadScores():
	if onlineMode:
		var data=networkHandler.getScoreboard()
		if data=="":
			printerr("[Scoreboard:loadScores] Wanted to get scoreboard, got empty string")
		else:
			print("scoreboard data received: ", str(data))
			data=data.replace('[',"")
			data=data.replace(']',"")
			data=data.replace("'","")
			data=data.replace("\n","")
			data=data.replace(" ","")
			print("sanitised data: ",data)
			var entries= data.split(",")
			print("entries: ", entries)
			
			for i in range(entries.size()-1):
				if i%2==0:
					names.append(entries[i])
					scores.append(entries[i+1].to_int())
			print("all names: ", names)
			print("all scores: ", scores)
			scoreBoardAvailable.emit()
	else:
		if not FileAccess.file_exists(FILE_PATH):
			return
		var file = FileAccess.open(FILE_PATH, FileAccess.READ)
		var data = ""
		while file.get_position() < file.get_length():
			data = file.get_line()
			var entry = data.split(',')
			names.append(entry[0])
			scores.append(entry[1].to_int())
		file.close()
	showLineEdit()
	updateScoreboard()

func _on_line_edit_text_submitted(new_text: String) -> void:
	if checkValidity(new_text):
		print("name is valid")
		addEntry(new_text,Global.overallScore)
		lineEditContainer.get_node("LineEdit").set_editable(false)
		#saveScores()
	else:
		print("name is not valid!")
