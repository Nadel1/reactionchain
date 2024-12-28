extends GenericPrompt
@export var input=""
@onready var animatedSprite=get_node("AnimatedSprite")
const hitSplat = preload("res://Scenes/Objects/FX/hitSplat.tscn")

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

func _process(delta: float) -> void:
	if global_position.y > 700 or global_position.x > 1200:
		call_deferred("queue_free")

func _on_button_good_area_area_entered(area: Area2D) -> void:
	goodHit=true
	if !launched and area.get_parent().is_in_group("InputPrompt") and speed < 1:
		launched = true
		velocity = Vector2(randf_range(-125.0,125.0), randf_range(-500.0,-250.0))
		var splat = hitSplat.instantiate()
		splat.global_position = global_position
		get_parent().add_child(splat)


func _on_button_okay_area_area_entered(_area: Area2D) -> void:
	okayHit=true
