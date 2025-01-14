extends GenericPrompt
class_name InputPrompt
@export var input=""
@onready var animatedSprite=get_node("AnimatedSprite")

var goodHit=false
var okayHit=false
var lastButton=false

func getInput():
	return input
	
func hitZoneEnter(enterHitZone):
	if enterHitZone: 
		animatedSprite.play("hit")
		okayHit=true
	else:
		animatedSprite.play("default")

func _process(_delta: float) -> void:
	if global_position.y > 700 or global_position.x > 1200:
		call_deferred("queue_free")

func freeze(_depth : int):
	pass

func _on_button_okay_area_area_entered(_area: Area2D) -> void:
	okayHit = true
	
func _on_button_good_area_area_entered(area: Area2D) -> void:
	goodHit = true

func _on_button_good_area_area_exited(area: Area2D) -> void:
	goodHit = false
