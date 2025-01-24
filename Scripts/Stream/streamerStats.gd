extends Node2D
class_name StreamerStats

var moneyPerBar = 1000.0
var tryingToRegen = false

func _ready() -> void:
	updateStats()
	Global.updateStreamerStats.connect(updateStats)

func _input(event):
	if event is InputEventKey:
		tryingToRegen = Input.is_action_pressed("regenerate")

func _process(delta: float) -> void:
	if tryingToRegen and Global.moneyEarned > 0:
		var moneySpent = Global.regenSpeed * delta
		Global.moneyEarned -= moneySpent
		Global.moneyEarned = max(0, Global.moneyEarned)
		if Global.health < 1:
			Global.health += (Global.regenPer100Money / 100.0) * moneySpent
			$MoneyAnim.play("RESET")
			$RegenParticles.emitting = true
		else:
			$MoneyAnim.play("turn_red")
			$RegenParticles.emitting = false
		updateStats()
	else:
		$MoneyAnim.play("RESET")
		$RegenParticles.emitting = false
	
	if Global.score <= 0:
		Global.health -= Global.healthLoss0Viewers * delta
		updateStats()
		Global.checkHealthGameOver()

func updateStats():
	$Health.setValue(Global.health)
	$Health/Background.modulate = lerp(Color(0.8,0.1,0.1), Color(0.1,0.1,0.1), Global.health * 2 if Global.health < 0.5 else 1.0)
	var moneyBars = floor(Global.moneyEarned / moneyPerBar)
	$MoneyCount.text = str(moneyBars) if moneyBars > 0 else ""
	var moneyFillLevel = float(Global.moneyEarned - (moneyPerBar * moneyBars)) / moneyPerBar
	$Money.setValue(moneyFillLevel)
	$Money/Background.modulate = Color(0.1,0.1,0.1) if moneyBars <= 0 else Color.GREEN
