extends Node2D

var lNames:Array[String]
var lScores:Array[int]

var glNames:Array[String]
var glScores:Array[int]

var globalScoreboard=false


const FILE_PATH="scores.save"

@onready var network=$NetworkHandler
@onready var namesLabelLocal=$NinePatchRect/MarginContainer/TabContainer/Local/HB1/Names
@onready var scoresLabelLocal=$NinePatchRect/MarginContainer/TabContainer/Local/HB1/Scores
@onready var namesLabelGlobal=$NinePatchRect/MarginContainer/TabContainer/Global/HB1/Names
@onready var scoresLabelGlobal=$NinePatchRect/MarginContainer/TabContainer/Global/HB1/Scores

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	network.scoreboardAvailable.connect(loadGlScoreboard)
	loadLocalScoreboard()
	buildScoreboard()

func loadLocalScoreboard():
	if not FileAccess.file_exists(FILE_PATH):
		var f=FileAccess.open_encrypted_with_pass(FILE_PATH, FileAccess.WRITE,"tsunamiii")
		f.close()
	var file=FileAccess.open_encrypted_with_pass(FILE_PATH, FileAccess.READ,"tsunamiii")
	var data=""
	while file.get_position() < file.get_length():
		data=file.get_line()
		var entry=data.split(',')
		lNames.append(entry[0])
		lScores.append(entry[1].to_int())
	file.close()

func loadGlScoreboard():
	globalScoreboard=true
	glNames=[]
	glScores=[]
	var s=network.getScoreboard()
	var data=s
	data=data.replace('[',"")
	data=data.replace(']',"")
	data=data.replace("'","")
	data=data.replace("\n","")
	data=data.replace(" ","")
	var entries= data.split(",")
	for i in range(min(entries.size()-1,20)):
		if i%2==0:
			glNames.append(entries[i])
			glScores.append(entries[i+1].to_int())
	buildScoreboard()

func buildScoreboard(lhighscore = -1, glhighscore = -1):
	#local
	namesLabelLocal.text=""
	scoresLabelLocal.text=""
	for i in range(lNames.size()):
		if(i == lhighscore):
			namesLabelLocal.text += "[color=green]"
			scoresLabelLocal.text += "[color=green]"
		if i<9:
			namesLabelLocal.text += "#"+str(i+1)+"  "+lNames[i]
			scoresLabelLocal.text += str(lScores[i])
		else:
			namesLabelLocal.text += "#"+str(i+1)+" "+lNames[i]
			scoresLabelLocal.text += str(lScores[i])
		if(i == lhighscore):
			namesLabelLocal.text += "[/color]\n"
			scoresLabelLocal.text += "[/color]\n"
		else:
			namesLabelLocal.text += "\n"
			scoresLabelLocal.text += "\n"
	#global
	if glNames.size() <= 0:
		return
	namesLabelGlobal.text=""
	scoresLabelGlobal.text=""
	for i in range(glNames.size()):
		if(i == lhighscore):
			namesLabelGlobal.text += "[color=green]"
			scoresLabelGlobal.text += "[color=green]"
		if i<9:
			namesLabelGlobal.text += "#"+str(i+1)+"  "+glNames[i]
			scoresLabelGlobal.text += str(glScores[i])
		else:
			namesLabelGlobal.text += "#"+str(i+1)+" "+glNames[i]
			scoresLabelGlobal.text += str(glScores[i])
		if(i == lhighscore):
			namesLabelGlobal.text += "[/color]\n"
			scoresLabelGlobal.text += "[/color]\n"
		else:
			namesLabelGlobal.text += "\n"
			scoresLabelGlobal.text += "\n"

func saveLocalScoreboard():
	var file= FileAccess.open_encrypted_with_pass(FILE_PATH, FileAccess.WRITE,"tsunamiii")
	for i in range(min(lNames.size(),10)):
		file.store_string(lNames[i]+","+str(lScores[i])+"\n")
	file.close()

func uploadGlobalScoreboard():
	if !globalScoreboard:
		return
	var sendScoreboard=""
	for i in range(min(glNames.size(),10)):
		sendScoreboard+=glNames[i]+","+str(glScores[i])+"\n"
	network.sendNewHighscore(sendScoreboard)

func addScore(name : String, score : int) -> bool:
	if !checkValidity(name):
		return false
	
	if lScores.size() == 0 or score > lScores[lScores.size()-1]:
		lScores.append(score)
		lNames.append(name)
	
	if globalScoreboard:
		if glScores.size() == 0 or score > glScores[glScores.size()-1]:
			glScores.append(score)
			glNames.append(name)
			#TODO some animation or sprite and sound to tell player he even 
			#managed to get onto the global leaderboard
			$NinePatchRect/MarginContainer/TabContainer.set_current_tab(1)
	
	sort()
	if lScores.size()>10:
		lScores.pop_back()
		lNames.pop_back()
	if glScores.size()>10:
		glScores.pop_back()
		glNames.pop_back()
	
	saveLocalScoreboard()
	uploadGlobalScoreboard()
	
	#TODO just finds first instance of score. Problem if duplicate scores
	var lindex=lScores.find(score)
	var rindex=glScores.find(score)
	buildScoreboard(lindex,rindex)
	return true

func checkHighScore(potentialHighScore:int):
	if lScores.size()==0 or glScores.size()==0:
		return true
	if potentialHighScore>=lScores[0] or potentialHighScore>=glScores[0]:
		return true
	else:
		return false

func checkNameEdit(score:int)->bool:
	if score>lScores[lScores.size()-1] or score>glScores[glScores.size()-1]:
		return true
	else:
		return false
		
func checkValidity(input:String):
	for i in input.length():
		print(input.unicode_at(i))
		if not((input.unicode_at(i)>=48 and input.unicode_at(i)<=57) or (input.unicode_at(i)>=65 and input.unicode_at(i)<=122)):
			return false
	return true

func sort():
	var scoresSorted:Array[int]
	scoresSorted=lScores.duplicate()
	scoresSorted.sort_custom(func(a,b):return a>b)
	var namesSorted=lNames.duplicate()
	var newIndex=0
	for i in range(lScores.size()):
		newIndex=scoresSorted.find(lScores[i])
		namesSorted[newIndex]=lNames[i]
	lNames=namesSorted
	lScores=scoresSorted
	
	if glNames.size()  <= 0:
		return
	scoresSorted=[]
	scoresSorted=glScores.duplicate()
	scoresSorted.sort_custom(func(a,b):return a>b)
	namesSorted=glNames.duplicate()
	newIndex=0
	for i in range(glScores.size()):
		newIndex=scoresSorted.find(glScores[i])
		namesSorted[newIndex]=glNames[i]
	glNames=namesSorted
	glScores=scoresSorted
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	#loadGlScoreboard()
	#buildScorboard()
	pass # Replace with function body.
