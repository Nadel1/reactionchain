extends GenericPrompt
@export var input=""
@onready var animatedSprite=get_node("AnimatedSprite")

var goodHit=false
var okayHit=false
var lastButton=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func getInput():
	return input
	
func hitZoneEnter(enterHitZone):
	if enterHitZone: 
		animatedSprite.play("hit")
		okayHit=true
	else:
		animatedSprite.play("default")


func _on_button_good_area_area_entered(_area: Area2D) -> void:
	goodHit=true


func _on_button_okay_area_area_entered(_area: Area2D) -> void:
	okayHit=true
