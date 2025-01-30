extends Node2D

var lNames:Array[String]
var lScores:Array[int]

var glNames:Array[String]
var glScores:Array[int]

const FILE_PATH="scores.save"

@onready var namesLabelLocal = $NinePatchRect/MarginContainer/TabContainer/Local/HB1/Names
@onready var scoresLabelLocal = $NinePatchRect/MarginContainer/TabContainer/Local/HB1/Scores
@onready var namesLabelGlobal = $NinePatchRect/MarginContainer/TabContainer/Global/HB1/Names
@onready var scoresLabelGlobal = $NinePatchRect/MarginContainer/TabContainer/Global/HB1/Scores

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadGlScoreboard()
	loadLocalScoreboard()
	pass # Replace with function body.

func loadLocalScoreboard():
	if not FileAccess.file_exists(FILE_PATH):
		var f = FileAccess.open_encrypted_with_pass(FILE_PATH, FileAccess.WRITE,"tsunamiii")
		f.close()
	var file = FileAccess.open_encrypted_with_pass(FILE_PATH, FileAccess.READ,"tsunamiii")
	var data = ""
	while file.get_position() < file.get_length():
		data = file.get_line()
		var entry = data.split(',')
		lNames.append(entry[0])
		lScores.append(entry[1].to_int())
	file.close()

func loadGlScoreboard():
	var s = Global.network.getScoreboard()
	var arr = str_to_var(s)
	for entry in arr:
		entry.split(',')
		glNames.append(entry[0])
		glScores.append(entry[1].to_int())

func buildScorboard():
	#local
	namesLabelLocal.text = ""
	scoresLabelLocal.text = ""
	for i in range(lNames.size()):
		namesLabelLocal.text += "#"+str(i)+" "+lNames[i]+"\n"
		scoresLabelLocal.text += str(lScores[i])+"\n"
	#global
	namesLabelGlobal.text = ""
	scoresLabelGlobal.text = ""
	for i in range(glNames.size()):
		namesLabelGlobal.text += "#"+str(i)+" "+glNames[i]+"\n"
		scoresLabelGlobal.text += str(glScores[i])+"\n"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
