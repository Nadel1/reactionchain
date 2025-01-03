extends GenericPrompt

var startIndicator = preload("res://Scenes/Objects/Buttons/EventStartIndicator.tscn")
@onready var startPos = global_position 

func _ready() -> void:
	$Label.visible = Global.developerMode

func _on_spawn_start_visual_timeout() -> void:
	var indicator = startIndicator.instantiate()
	get_parent().add_child(indicator)
	indicator.global_position = startPos
