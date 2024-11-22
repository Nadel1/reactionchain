class_name RT

enum Direction {UP, RIGHT, DOWN, LEFT}
enum Emotion {POG, LAUGH, ANGRY, CRINGE}

static func intToDir(index:int):
	match(index):
		0:
			return Emotion.POG
		1: 
			return Emotion.LAUGH
		2: 
			return Emotion.ANGRY
		3: 
			return Emotion.CRINGE
				
static func dirToStr(direction : Direction):
	match(direction):
		Direction.UP:
			return "up"
		Direction.RIGHT:
			return "right"
		Direction.DOWN:
			return "down"
		Direction.LEFT:
			return "left"

static func emoteToStr(emotion : Emotion):
	match(emotion):
		Emotion.POG:
			return "pog"
		Emotion.LAUGH:
			return "laugh"
		Emotion.ANGRY:
			return "angry"
		Emotion.CRINGE:
			return "cringe"
