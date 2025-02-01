extends Node2D

var names:Array[String]
var scores:Array[int]
var onlineScoreboard=""

@onready var nameValues=$MarginContainer/VBoxContainer/GridContainer/NameValues
@onready var scoreValues=$MarginContainer/VBoxContainer/GridContainer/ScoreValues
@onready var lineEditContainer= $MarginContainer/VBoxContainer/HBoxContainerLineEdit
@onready var networkHandler=$NetworkHandler

var addedScoreToLocal=false
var addedScoreToOnline=false
signal changedScoreboard

const FILE_PATH="scores.save"

signal scoreBoardAvailable
func _ready() -> void:
	Global.onlineMode=true
	networkHandler.offline.connect(updateOffline)
	networkHandler.scoreboardAvailable.connect(loadScores)
	if Global.url=="":
		updateOffline()
	
func updateOffline():
	Global.cannotConnect=true
	nameValues.text="No connection!"
	scoreValues.text="No connection!"
	lineEditContainer.hide()

func showLineEdit():
	if get_parent()!=null and get_parent().name=="MainMenu":
		return  
	if scores.size()<=1 or Global.overallScore>scores[scores.size()-1] or scores.size()<10:
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
			nameValues.text+=" > #"+str(i+1)+"  "+names[i]+'\n'
		else:	
			nameValues.text+=" > #"+str(i+1)+"   "+names[i]+'\n'
		scoreValues.text+= " "+str(scores[i])+'\n'

func checkHighScore(potentialHighScore:int):
	if scores.size()==0:
		return true
	if potentialHighScore>=scores[0]:
		return true
	else:
		return false
	
func checkValidity(input:String):
	for i in input.length():
		print(input.unicode_at(i))
		if not((input.unicode_at(i)>=48 and input.unicode_at(i)<=57) or (input.unicode_at(i)>=65 and input.unicode_at(i)<=122)):
			return false
	return true
		
func addEntry(name:String,score:int):
	names.append(name)
	scores.append(score)
	updateScoreboard()
	
	
func saveScores():
	if Global.onlineMode:
		onlineScoreboard=""
		var sendScoreboard=""
		for i in range(min(names.size(),10)):
			sendScoreboard+=names[i]+","+str(scores[i])+"\n"
			onlineScoreboard+=names[i]+","+str(scores[i])+","
		networkHandler.sendNewHighscore(sendScoreboard)
	else:
		var file= FileAccess.open_encrypted_with_pass(FILE_PATH, FileAccess.WRITE,"tsunamiii")
		for i in range(min(names.size(),10)):
			file.store_string(names[i]+","+str(scores[i])+"\n")
		file.close()
	
func loadScores():
	names=[]
	scores=[]
	if Global.onlineMode:
		if Global.cannotConnect:
			updateOffline()
			return
		var data=""
		if onlineScoreboard=="":
			data=networkHandler.getScoreboard()
		else:
			data=onlineScoreboard
		if data=="":
			printerr("[Scoreboard:loadScores] Wanted to get scoreboard, got empty string")
		else:
			print("scoreboard data received: ", str(data))
			data=data.replace('[',"")
			data=data.replace(']',"")
			data=data.replace("'","")
			data=data.replace("\n","")
			data=data.replace(" ","")
			var entries= data.split(",")
			for i in range(min(entries.size()-1,20)):
				if i%2==0:
					names.append(entries[i])
					scores.append(entries[i+1].to_int())
			scoreBoardAvailable.emit()
	else:
		if not FileAccess.file_exists(FILE_PATH):
			var f = FileAccess.open_encrypted_with_pass(FILE_PATH, FileAccess.WRITE,"tsunamiii")
			f.close()
		var file = FileAccess.open_encrypted_with_pass(FILE_PATH, FileAccess.READ,"tsunamiii")
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
		if Global.onlineMode and addedScoreToOnline:
			return
		if !Global.onlineMode and addedScoreToLocal:
			return
		addEntry(new_text,Global.overallScore)
		if Global.onlineMode:
			addedScoreToOnline=true
		else:
			addedScoreToLocal=true
		lineEditContainer.get_node("LineEdit").set_editable(false)
		saveScores()
	else:
		print("name is not valid!")
		return

func _on_tab_bar_tab_changed(tab: int) -> void:
	lineEditContainer.get_node("LineEdit").set_editable(true)
	if tab==0:
		Global.onlineMode=true
		if addedScoreToOnline:
			lineEditContainer.get_node("LineEdit").set_editable(false)
	else:
		Global.onlineMode=false
		if addedScoreToLocal:
			lineEditContainer.get_node("LineEdit").set_editable(false)
	loadScores()
	changedScoreboard.emit()
