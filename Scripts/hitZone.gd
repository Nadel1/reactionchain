extends Node2D

var perfectHit=false
var goodHit=false
var buttonPrompt=null
@onready var animatedSprite=$HitZoneAnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("right"):
			registerInput("right")
		elif event.is_action_pressed("left"):
			registerInput("left")
		elif event.is_action_pressed("up"):
			registerInput("up")
		elif event.is_action_pressed("down"):
			registerInput("down")
		else:
			print("bullshit was pressed")
			

func registerInput(inputString):
	get_parent().removeFirstButtonPrompt()
	if buttonPrompt!=null: #check to see if there is a button in the hitzone
		if buttonPrompt.getInput()==inputString:
			animatedSprite.play("hit")
		else: 
			animatedSprite.play("default")
		buttonPrompt=null
		
func _on_good_area_area_entered(area: Area2D) -> void:
	buttonPrompt=area.get_parent()
	buttonPrompt.hitZoneEnter(true)
	goodHit=true


func _on_good_area_area_exited(area: Area2D) -> void:
	buttonPrompt=null
	goodHit=false
	get_parent().removeFirstButtonPrompt()
