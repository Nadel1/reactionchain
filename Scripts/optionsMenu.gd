extends Node2D

func _ready() -> void:
	$Devmode.button_pressed = Global.developerMode
	$PerformanceMode.button_pressed = Global.performanceMode

func _on_close_button_down() -> void:
	visible = false

func _on_devmode_toggled(toggled_on: bool) -> void:
	Global.developerMode = toggled_on

func _on_performance_mode_toggled(toggled_on: bool) -> void:
	Global.performanceMode = toggled_on
	Global.recordingDepth = 3 if toggled_on else 7
	Global.chatDepth = 3 if toggled_on else 5

func _on_reset_save_file_button_down() -> void:
	Global.resetSaveFile()
