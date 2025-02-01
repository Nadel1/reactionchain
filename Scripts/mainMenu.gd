extends Node2D

@onready var scoreboard=$scoreboard2

func _on_start_button_down() -> void:
	Global.prepareGame(false)
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")

func _on_options_button_down() -> void:
	$OptionsMenu.visible = !$OptionsMenu.visible

func _on_quit_button_down() -> void:
	get_tree().quit()

func _on_tutorial_button_down() -> void:
	Global.prepareGame()
	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")
	
func _on_scoreboard_button_down() -> void:
	if scoreboard.visible:
		scoreboard.hide()
	else:
		scoreboard.show()
