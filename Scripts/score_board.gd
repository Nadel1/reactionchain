extends Node2D

var names:Array[String]
var scores:Array[int]

@onready var nameValues=$MarginContainer/VBoxContainer/GridContainer/NameValues
@onready var scoreValues=$MarginContainer/VBoxContainer/GridContainer/ScoreValues
@onready var lineEditContainer= $MarginContainer/VBoxContainer/HBoxContainerLineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadScores("scores.save")
	updateScoreboard()
	saveScores("scores.save")

func showLineEdit():
	if Global.overallScore>scores[scores.size()-1]:
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
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	saveScores("scores.save")
func checkHighScore(potentialHighScore:int):
	if potentialHighScore>scores[0]:
		return true
	else:
		return false
func addEntry(name:String,score:int):
	names.append(name)
	scores.append(score)
	updateScoreboard()
	
	
func saveScores(filepath:String):
	var file= FileAccess.open(filepath, FileAccess.READ_WRITE)
	for i in range(names.size()):
		file.store_line(names[i]+","+str(scores[i]))
	file.close()
	
func loadScores(filepath : String):
	if not FileAccess.file_exists(filepath):
		return
	var file = FileAccess.open(filepath, FileAccess.READ)
	var data = ""
	while file.get_position() < file.get_length():
		data = file.get_line()
		var entry = data.split(',')
		names.append(entry[0])
		scores.append(entry[1].to_int())
	file.close()

func _on_line_edit_text_submitted(new_text: String) -> void:
	addEntry(new_text,Global.overallScore)
	lineEditContainer.get_node("LineEdit").set_editable(false)
