extends Node2D

const DONATION_INPUT=preload("res://Scenes/Objects/Donations/donationInput.tscn")
var donationInputsBanner
var donationInputKeys=["W","A","S","D"]
var inputAnimations=["up_shake","left_shake","down_shake","right_shake"]
var sizeOfBanner=100
var expectedInputOrder=[]
var inputArray=[]
var compareIndex=0
var failed = false
@onready var notificationSprite=$Notification
@onready var outlineSprite=$Outline
@onready var donationsBanner=$DonationsBanner
@onready var donationAnim=$AnimationPlayerOutline
@onready var playerFeedbackAnim=$AnimationPlayerFeedback
@export var videoOverlay:AnimatedSprite2D
@onready var animPlayerRotate=$AnimationPlayerRotate


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
		playerFeedbackAnim.play(inputAnimations.pick_random())
		compareIndex+=1
		if compareIndex>=inputArray.size():
			donationsBanner.hide()
			correctDonation()
		else: 
			inputArray[compareIndex].find_child("AnimatedSprite2DBackground").play(str("blinking"+expectedInputOrder[compareIndex]))
	else:
		fail()
	
func correctDonation():
	$Success.play()
	notificationSprite.play("success")
	outlineSprite.hide()
	Global.moneyEarned+=Global.increaseInMoney
	#Global.increaseInMoney+=Global.increaseInMoney+randi()%(Global.increaseInMoney/4)
	Global.nextDonationViewerCount+=Global.donationIncrease
	var ui=get_parent()
	ui.get_node("Money/MoneyVFX").show()
	ui.get_node("Money/MoneyVFX").play("money")
	Global.moneyManager.updateMoneyDisplay()
			
func loadDonation(donationLevel):
	donationInputsBanner=find_child("DonationsBanner")
	turnOn()
	for i in range(0,donationLevel):
		var donationInput=DONATION_INPUT.instantiate()
		var inputString=donationInputKeys.pick_random()
		donationInput.find_child("AnimatedSprite2DBackground").play(str("default"+inputString))
		donationsBanner.add_child(donationInput)
		inputArray.append(donationInput)
		expectedInputOrder.append(inputString)
		var offset= Vector2(1,0)*sizeOfBanner/(donationLevel-1)
		donationInput.position=offset*i-Vector2(1,0)*sizeOfBanner/2
		donationInput.scale=Vector2(1,1)
	inputArray[0].find_child("AnimatedSprite2DBackground").play(str("blinking"+expectedInputOrder[0]))
	
	
func fail():
	Global.currentStreamer.donationReaction(false)
	for i in range(0, inputArray.size()):
		inputArray[i].hide()
	notificationSprite.play("fail")
	donationsBanner.hide()
	outlineSprite.hide()
	Global.score-=Global.score/5
	Global.score = min(Global.score, Global.nextDonationViewerCount/2)
	$Fail.play()
	failed = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="popUp":
		donationAnim.play("timeForReaction")
	else:		
		fail()
		


func _on_end_dontation_timer_timeout() -> void:
	Global.donationOnScreen=false
	turnOff()

func playNotificationBannerAnim():
	donationAnim.play("popUp")
	
func turnOff():
	notificationSprite.hide()
	outlineSprite.hide()
	videoOverlay.hide()
	donationsBanner.hide()
	donationAnim.stop()
	#endDonationTimer.stop()
	
func turnOn():
	$Popup.play()
	failed=false
	compareIndex=0
	animPlayerRotate.play("rotate")
	expectedInputOrder=[]
	Global.donationOnScreen=true
	notificationSprite.show()
	outlineSprite.show()
	donationsBanner.show()
	notificationSprite.play("default")
	outlineSprite.play("default")
	inputArray=[]
	videoOverlay.show()
	donationAnim.play("timeForReaction")
	
func _on_notification_animation_finished() -> void:
	Global.donationOnScreen=false
	turnOff()

func _on_donation_animation_animation_finished(anim_name: StringName) -> void:
	donationAnim.play("popUp")


func _on_notification_animation_changed() -> void:
	if notificationSprite.animation=="success" or notificationSprite.animation=="fail":
		animPlayerRotate.play("RESET")
