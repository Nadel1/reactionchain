extends Node2D

const DONATION_INPUT=preload("res://Scenes/Objects/Donations/donationInput.tscn")
var donationInputsBanner
var donationInputKeys=["W","A","S","D"]
var inputAnimations=["up_shake","left_shake","down_shake","right_shake"]
var sizeOfBanner=200
var expectedInputOrder=[]
var inputArray=[]
var compareIndex=0
var failed = false
@onready var endDonationTimer=$EndDontationTimer

func _input(event):
	if not failed and event is InputEventKey and event.pressed and compareIndex<expectedInputOrder.size():
		if event.pressed and event.keycode==KEY_W:
			dealWithInput(expectedInputOrder[compareIndex]=="W")
		if event.pressed and event.keycode==KEY_A:
			dealWithInput(expectedInputOrder[compareIndex]=="A")
		if event.pressed and event.keycode==KEY_S:
			dealWithInput(expectedInputOrder[compareIndex]=="S")
		if event.pressed and event.keycode==KEY_D:
			dealWithInput(expectedInputOrder[compareIndex]=="D")

func dealWithInput(correctInput):
	if correctInput:
		Global.currentStreamer.donationReaction(true)
		inputArray[compareIndex].hide()
		$AnimationPlayerFeedback.play(inputAnimations.pick_random())
		compareIndex+=1
		if compareIndex>=inputArray.size():
			correctDonation()
		else: 
			inputArray[compareIndex].find_child("AnimatedSprite2DBackground").play(str("blinking"+expectedInputOrder[compareIndex]))
	else:
		crumble()
	
func correctDonation():
	$Success.play()
	$Notification.play("open")
	$Outline.play("open")
	$ReceivedAnim.show()
	$ReceivedAnim.play("default")
	$AnimationPlayerFeedback.play("growReceivedBackground")
	$DonationsBanner.hide()
	Global.moneyEarned+=Global.increaseInMoney
	#Global.increaseInMoney+=Global.increaseInMoney+randi()%(Global.increaseInMoney/4)
	Global.nextDonationViewerCount+=Global.donationIncrease
	endDonationTimer.start()
	var ui=get_parent()
	ui.get_node("Money/MoneyVFX").show()
	ui.get_node("Money/MoneyVFX").play("money")
	Global.moneyManager.updateMoneyDisplay()
			
func loadDonation(donationLevel):
	donationInputsBanner=find_child("DonationsBanner")
	Global.donationOnScreen=true
	$Notification.play("default")
	$ReceivedAnim.hide()
	$Outline.play("default")
	for i in range(0,donationLevel):
		var donationInput=DONATION_INPUT.instantiate()
		var inputString=donationInputKeys.pick_random()
		donationInput.find_child("AnimatedSprite2DBackground").play(str("default"+inputString))
		add_child(donationInput)
		inputArray.append(donationInput)
		expectedInputOrder.append(inputString)
		var offset= Vector2(1,0)*sizeOfBanner/(donationLevel-1)
		donationInput.position=donationInputsBanner.position+offset*i-Vector2(1,0)*sizeOfBanner/2
	inputArray[0].find_child("AnimatedSprite2DBackground").play(str("blinking"+expectedInputOrder[0]))
	#$AnimationPlayerOutline.play("movement")
	
	
func crumble():
	Global.currentStreamer.donationReaction(false)
	for i in range(0, inputArray.size()):
		inputArray[i].hide()
	$Notification.play("crumble")
	$Outline.play("crumble")
	$DonationsBanner.hide()
	Global.score-=Global.score/5
	Global.score = min(Global.score, Global.nextDonationViewerCount/2)
	$Fail.play()
	failed = true

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
		crumble()


func _on_end_dontation_timer_timeout() -> void:
	get_parent().find_child("DonationBackground").hide()
	Global.donationOnScreen=false
	self.queue_free()


func _on_notification_animation_finished() -> void:
	if $Notification.animation=="crumble":
		Global.donationOnScreen=false
		get_parent().find_child("DonationBackground").hide()
		self.queue_free()
