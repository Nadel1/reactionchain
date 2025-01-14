extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$OptionsMenu/Devmode.button_pressed = Global.developerMode
	$Text/ScoreText.text="[center]"+"Most viewers: "+str(Global.currentHighScoreViewers)+"[/center]"
	$Text/MoneyText.text="[center]"+"Money: "+str(int(Global.moneyEarned))+"[/center]"
	Global.overallScore=Global.currentHighScoreViewers+int(Global.survivedTime)+Global.moneyEarned
	$Text/OverallScoreText.text="[center] Overall score: "+str(Global.overallScore)
	if Global.overallScore>Global.overallScoreHighScore:
		$Text/HighScore.show()
		Global.overallScoreHighScore=Global.overallScore
	else: 
		$Text/HighScore.hide()
	var time=int(Global.survivedTime)
	var strMinutes=str(time/60)
	if (time/60)<10:
		strMinutes="0"+strMinutes
	var strSeconds=str(time%60)
	if (time%60)<10:
		strSeconds="0"+strSeconds
	$Text/TimeScoreText.text="[center]"+"Time: "+strMinutes+":"+strSeconds+"[/center]"

func _on_restart_button_down() -> void:
	Global.score=10
	Global.nextDonationViewerCount=500
	Global.currentHighScoreViewers=0
	Global.mainSeed=randi()
	Global.currentStreamIndex=0
	Global.increaseInMoney=100
	Global.moneyEarned=100
	Global.startSurvivedTime()
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
	


func _on_delete_savefile_button_pressed() -> void:
	Global.resetSaveFile()
