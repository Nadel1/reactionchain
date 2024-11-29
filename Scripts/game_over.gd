extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Text/ScoreText.text="[center]"+"Highest score: "+str(Global.currentHighScore)+"[/center]"


func _on_restart_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")


func _on_quit_game_button_down() -> void:
	get_tree().quit()
