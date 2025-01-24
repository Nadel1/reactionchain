extends Node2D

var names:Array[String]
var scores:Array[int]

@onready var itemListName=$MarginContainer/VBoxContainer/HBoxContainer2/ItemListName
@onready var itemListScore=$MarginContainer/VBoxContainer/HBoxContainer2/ItemListScore

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadScores("scores.save")
	updateScoreboard()
	saveScores("scores.save")

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
	itemListName.clear()
	itemListScore.clear()
	for i in range(names.size()):
		itemListName.add_item("#"+str(i+1)+" "+names[i])
		itemListScore.add_item(str(scores[i]))

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
