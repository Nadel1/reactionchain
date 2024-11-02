extends Node2D
@export var speed = 100
@export var input=""

@onready var animatedSprite=get_node("AnimatedSprite")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += Vector2(speed * delta,0)
	
func getInput():
	return input
	
func hitZoneEnter(enterHitZone):
	if enterHitZone: 
		animatedSprite.play("hit")
	else:
		animatedSprite.play("default")
