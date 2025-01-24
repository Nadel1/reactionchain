extends Node
class_name TrackSnippet

enum SnippetType {A, B}

@export var type : SnippetType
@export_file("*.MID") var layers : Array[String]
@export_file("*.MID") var extremeLayer 

func getLayer(index : int):
	var above = index - layers.size()
	var actualIndex = max(0,min(index, layers.size()-2))
	if above > 0:
		actualIndex += above % 2
	var hardMode = (rand_from_seed(index + Global.mainSeed)[0] % 10) < above
	return extremeLayer if hardMode else layers[actualIndex]
