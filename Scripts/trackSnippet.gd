extends Node
class_name TrackSnippet

enum SnippetType {A, B}

@export var type : SnippetType
@export_file("*.MID") var layers : Array[String]

func getLayer(index : int):
	#return layers[index % layers.size()]
	return layers[min(index, layers.size()-1)]
