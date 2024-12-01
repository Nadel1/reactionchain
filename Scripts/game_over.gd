extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.currentHighScore>Global.highScore:
		Global.highScore=Global.currentHighScore
		$Text/HighScore.visible=true
	else:
		$Text/HighScore.visible=false
	$Text/ScoreText.text="[center]"+"Highest score: "+str(Global.currentHighScore)+"[/center]"


func _on_restart_button_down() -> void:
	Global.score=0
	Global.currentHighScore=0
	Global.mainSeed=randi()
	Global.currentStreamIndex=0
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")


func _on_quit_game_button_down() -> void:
	Global.saveGame()
	get_tree().quit()


func _on_options_button_down() -> void:
	$OptionsMenu.visible = true


func _on_quit_menu_button_pressed() -> void:
	$OptionsMenu.visible = false


func _on_devmode_toggled(toggled_on: bool) -> void:
	Global.developerMode=toggled_on
	
