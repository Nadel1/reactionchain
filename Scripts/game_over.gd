extends Node2D

@onready var scoreboard=$Text/scoreboard2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	$Background/BackgroundText.text="> Technical difficulties ...\n"
	if Global.score<=0:
		$Background/BackgroundText.text+= "> You have become irrelevant\n"
	elif Global.moneyEarned <1:
		$Background/BackgroundText.text+= "> No funds remaining\n"
	$Background/BackgroundText.text+= "> Shutting off ..."
	$OptionsMenu/Devmode.button_pressed = Global.developerMode
	$Text/ScoreText.text="[center]"+"Most viewers: "+str(Global.currentHighScoreViewers)+"[/center]"
	$Text/MoneyText.text="[center]"+"Most money: "+str(int(Global.currentMoneyHighScore))+"[/center]"
	Global.overallScore=Global.currentHighScoreViewers+int(Global.survivedTime)+int(Global.currentMoneyHighScore)
	Global.moneyHighScore = max(Global.moneyHighScore, Global.currentMoneyHighScore)
	$Text/Score/OverallScoreText.text="[center] Overall score: "+str(Global.overallScore)
	
	var time=int(Global.survivedTime)
	var strMinutes=str(time/60)
	if (time/60)<10:
		strMinutes="0"+strMinutes
	var strSeconds=str(time%60)
	if (time%60)<10:
		strSeconds="0"+strSeconds
	$Text/TimeScoreText.text="[center]"+"Time: "+strMinutes+":"+strSeconds+"[/center]"

	
func showHighScoreText():
	if scoreboard.checkHighScore(Global.overallScore):
		$Text/HighScore.show()
	else: 
		$Text/HighScore.hide()
		
func _on_restart_button_down() -> void:
	Global.prepareGame()
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")

func _on_quit_game_button_down() -> void:
	get_tree().quit()

func _on_options_button_down() -> void:
	$OptionsMenu.visible = !$OptionsMenu.visible

func _on_to_main_menu_button_down() -> void:
	Global.prepareGame()
	get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if scoreboard.checkHighScore(Global.overallScore):
		$Text/Score/OverallScoreText.text="[center] NEW HIGHSCORE: "+str(Global.overallScore)+"[/center]"
		$Text/Score/AnimationPlayer.play("HighscoreJiggle")
	if scoreboard.checkNameEdit(Global.overallScore):
		$Text/NameEnter.show()
	pass # Replace with function body.


func _on_line_edit_text_submitted(new_text: String) -> void:
	if scoreboard.checkValidity(new_text):
		scoreboard.addScore(new_text, Global.overallScore)
		$Text/NameEnter/NinePatchRect/LineEdit.hide()
		$Text/NameEnter/AnimationPlayer.play("Zoom")
		$Text/NameEnter/ErrorMessage.hide()
	else:
		$Text/NameEnter/AnimationPlayer.play("Error")
		$Text/NameEnter/ErrorMessage.show()
	pass # Replace with function body.
