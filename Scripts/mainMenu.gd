extends Node2D

func _ready() -> void:
	$OptionsMenu/Devmode.button_pressed = Global.developerMode
	$OptionsMenu/PerformanceMode.button_pressed = Global.performanceMode
	$OptionsMenu/Difficulty.value = 5 - Global.difficulty

func _on_start_button_down() -> void:
	Global.prepareGame()
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")


func _on_options_button_down() -> void:
	$OptionsMenu.visible = !$OptionsMenu.visible


func _on_quit_button_down() -> void:
	Global.saveGame()
	get_tree().quit()


func _on_difficulty_value_changed(value: float) -> void:
	Global.difficulty = int(4 - value)


func _on_devmode_toggled(toggled_on: bool) -> void:
	Global.developerMode = toggled_on


func _on_reset_save_file_pressed() -> void:
	Global.resetSaveFile()


func _on_performance_mode_toggled(toggled_on: bool) -> void:
	Global.performanceMode = toggled_on
	Global.chatDepth = 3 if toggled_on else 5
