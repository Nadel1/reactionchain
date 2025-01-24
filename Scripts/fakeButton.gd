extends InputPrompt

const hitSplat = preload("res://Scenes/Objects/FX/hitSplat.tscn")
const directions = ["up","right","down","left"]

func setDirection():
	var index = randi_range(0,3)
	$Sprite.play(directions[index])

func _on_button_good_area_area_entered(area: Area2D) -> void:
	if !launched and area.get_parent().is_in_group("InputPrompt"):# and speed < 1:
		launched = true
		velocity = Vector2(randf_range(-125.0,125.0), randf_range(-750.0,-250.0))
		angularVelocity = randf_range(-6, 6)
		var splat = hitSplat.instantiate()
		splat.global_position = global_position
		get_parent().add_child(splat)

func freeze(depth : int):
	if !fast and depth == Global.currentStreamIndex:
		speed = 0
