extends Node2D

const DONATION_INPUT=preload("res://Scenes/Objects/Donations/donationInput.tscn")
var donationInputsBanner
var donationInputKeys=["W","A","S","D"]
var inputAnimations=["up_shake","left_shake","down_shake","right_shake"]
var sizeOfBanner=200
var expectedInputOrder=[]
var inputArray=[]
var compareIndex=0

func _input(event):
	if event is InputEventKey and event.pressed and compareIndex<expectedInputOrder.size():
		if event.pressed and event.keycode==KEY_W:
			if expectedInputOrder[compareIndex]!="W":
				dealWithInput(false)
			else: 
				dealWithInput(true)
		if event.pressed and event.keycode==KEY_A:
			if expectedInputOrder[compareIndex]!="A":
				dealWithInput(false)
			else: 
				dealWithInput(true)
		if event.pressed and event.keycode==KEY_S:
			if expectedInputOrder[compareIndex]!="S":
				dealWithInput(false)
			else: 
				dealWithInput(true)
		if event.pressed and event.keycode==KEY_D:
			if expectedInputOrder[compareIndex]!="D":
				dealWithInput(false)
			else: 
				dealWithInput(true)

func dealWithInput(correctInput):
	if correctInput:
		inputArray[compareIndex].hide()
		$AnimationPlayerFeedback.play(inputAnimations.pick_random())
		compareIndex+=1
		if compareIndex>=inputArray.size():
			correctDonation()
		else: 
			inputArray[compareIndex].find_child("Outline").show()
	else:
		print("wrong donation")
		for i in range(0, inputArray.size()):
			inputArray[i].hide()
		$Notification.play("crumble")
		$Outline.play("crumble")
		$DonationsBanner.hide()
		

	
func correctDonation():
	$Notification.play("open")
	$Outline.play("open")
	$ReceivedAnim.show()
	$ReceivedAnim.play("default")
	$AnimationPlayerFeedback.play("growReceivedBackground")
	$DonationsBanner.hide()
			
func loadDonation(donationLevel):
	$ReceivedAnim.hide()
	donationInputsBanner=find_child("DonationsBanner")
	Global.donationOnScreen=true
	$Notification.play("default")
	$Outline.play("default")
	for i in range(0,donationLevel):
		var donationInput=DONATION_INPUT.instantiate()
		var inputString=donationInputKeys.pick_random()
		donationInput.find_child("Input").text="[center]"+inputString+"[/center]"
		add_child(donationInput)
		inputArray.append(donationInput)
		expectedInputOrder.append(inputString)
		var offset= Vector2(1,0)*sizeOfBanner/(donationLevel-1)
		donationInput.position=donationInputsBanner.position+offset*i-Vector2(1,0)*sizeOfBanner/2
	inputArray[0].find_child("Outline").show()
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	Global.donationOnScreen=false
	self.queue_free()


func _on_end_dontation_timer_timeout() -> void:
	Global.donationOnScreen=false
	self.queue_free()


func _on_notification_animation_finished() -> void:
	if $Notification.animation=="crumble":
		Global.donationOnScreen=false
		self.queue_free()
