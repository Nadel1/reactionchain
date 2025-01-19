extends Label
class_name DebugWindow

var values : Dictionary

func _ready() -> void:
	Global.debugWindow = self
	get_parent().visible = Global.developerMode

func setEntry(key, value):
	values[key] = value
	
	var textComposite = ""
	for existingKey in values:
		textComposite += str(existingKey) + ": " + str(values[existingKey]) + "\n"
	
	text = textComposite
