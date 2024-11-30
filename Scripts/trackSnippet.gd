extends Node
class_name TrackSnippet

@export_file("*.MID") var layers : Array[String]

func getLayer(index : int):
	return layers[index % layers.size()]
