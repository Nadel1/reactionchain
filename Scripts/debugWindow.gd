extends Label
class_name DebugWindow

var values : Dictionary

func setEntry(key, value):
	values[key] = value
	
	var textComposite = ""
	for existingKey in values:
		textComposite += str(existingKey) + ": " + str(values[existingKey]) + "\n"
	
	text = textComposite
