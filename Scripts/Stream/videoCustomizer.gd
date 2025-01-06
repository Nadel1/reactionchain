extends Node2D
class_name VideoCustomizer

@export var streamBorders : Array[Texture]

# TODO: better system that supports streamer names
const titles = [
	["Reaction:", "My response to:", "Random guy reacts:", "I react to:"],
	["Can you believe this?", "One weird trick", "Top 10 things", "One of the things of all time",
	"I don't know what this is", "People doing things again", "Epic fail compilation #1486"],
	["- GONE WRONG", "- MENTAL", "- WHAT?!", "", ""]
]
const spices = [857167209, 9816348721, 98239659]
var layerIndex = 0

func _ready() -> void:
	Global.pause.connect(pause)
	Global.resume.connect(resume)

func init(index : int):
	layerIndex = index
	var prefixStack = ""
	for i in range(0, index):
		prefixStack = Global.videoTitle[0][i] + " " + prefixStack
	var suffixStack = ""
	for i in range(0, index):
		suffixStack = Global.videoTitle[2][(index - 1) - i] + " " + suffixStack
	var text = prefixStack + Global.videoTitle[1][0] + " " + suffixStack
	text = text.strip_edges()
	$Title.text = text
	
	var hue = (rand_from_seed(index + Global.mainSeed)[0]%1000)/1000.0
	hue = fmod((hue + 0.1), 1.0)
	var value = (rand_from_seed(index + 10 + Global.mainSeed)[0]%1000)/1000.0
	value = 0.6 + 0.4 * (1-value * value)
	$Background.color = Color.from_hsv(hue, 0.2, value * 0.79)
	$StreamBorder.modulate = Color.from_hsv(hue, 0.2, value)
	var textureIndex = rand_from_seed(index + 10 + Global.mainSeed)[0] % streamBorders.size()
	$StreamBorder.texture = streamBorders[textureIndex]
	
	$Time.wait_time = (Global.musicTracks[index].size() + 2) * Global.snippetLength
	$Time.start()

static func generateFirstTitle():
	Global.videoTitle[1].append(getString(1, 0))

static func extendTitle(index : int):
	Global.videoTitle[0].append(getString(0, index))
	Global.videoTitle[2].append(getString(2, index))

static func getString(part : int, stringSeed : int):
	if part > 0 or stringSeed > 0:
		var at = rand_from_seed(stringSeed + spices[part] + Global.mainSeed)[0] % titles[part].size()
		return titles[part][at]
	return ""

func pause(depth):
	if depth == layerIndex:
		$PausePlay.play("pause")
	$Time.set_paused(depth >= layerIndex)

func resume(depth):
	if depth == layerIndex:
		$PausePlay.play("play")
	$Time.set_paused(not depth >= layerIndex)

func _process(_delta: float) -> void:
	$TimelineProgress.scale.x = 1 - $Time.time_left / $Time.wait_time
	
