extends Node2D


func _on_start_button_down() -> void:
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")


func _on_options_button_down() -> void:
	pass # Replace with function body.


func _on_quit_button_down() -> void:
	get_tree().quit()
