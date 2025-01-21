extends Node2D
class_name FakePromptSpawner

@export var spawnPos : Node2D
const button = preload("res://Scenes/Objects/Buttons/FakeButton.tscn")

func _ready() -> void:
	Global.tactFakeArrows.connect(start)
	$MidiPlayerArrows.setName("FakeArrows")
	$MidiPlayerArrows.play_speed = Global.playbackSpeed

func start():
	$MidiPlayerArrows.play()

func spawnButton():
	var newButton = button.instantiate()
	newButton.global_position = spawnPos.global_position
	get_parent().get_parent().add_child(newButton)
	newButton.setDirection()

func _on_midi_player_arrows_midi_event(_channel: Variant, event: Variant) -> void:
	if event.type == 144:
		if event.velocity > 5:
			spawnButton()
