extends Node2D
class_name MoneyManager

var streamRunning = false

func _ready() -> void:
	Global.moneyManager = self
	Global.tact.connect(updateStreamState)
	updateMoneyDisplay(false)

#func _process(delta: float) -> void:
	#if streamRunning:
		#Global.moneyEarned -= delta * Global.moneyLoss
		#updateMoneyDisplay()

func updateStreamState(snippetIndex):
	streamRunning = snippetIndex < Global.musicTracks.back().size()

func updateMoneyDisplay(allowGameOver = true):
	var moneyAmount = int(Global.moneyEarned)
	var displayedMoney=str(moneyAmount)
	if moneyAmount>1000 and moneyAmount<1000000:
		displayedMoney=str(moneyAmount/1000)+"."+str((moneyAmount%1000)/100)
		displayedMoney=str(displayedMoney)+"k"
	elif moneyAmount>1000000:
		displayedMoney=str(moneyAmount/1000000)+"."+str((moneyAmount%1000000)/100000)
		displayedMoney=str(displayedMoney)+"m"
	Global.displayedMoney=displayedMoney
	$Text.text="Money: "+str(displayedMoney)
	if moneyAmount < Global.moneyLoss * 10:
		$Warning.play("warning")
		if moneyAmount <= 0 and allowGameOver:
			pass
			#Global.gameOver()
	else:
		$Warning.play("default")
