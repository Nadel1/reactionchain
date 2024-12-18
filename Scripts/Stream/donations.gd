extends Node2D

const DONATION_INPUT=preload("res://Scenes/Objects/Donations/donationInput.tscn")
var donationInputsBanner
var donationInputKeys=["W","A","S","D"]
var sizeOfBanner=200
var expectedInputOrder=[]
var inputArray=[]
var compareIndex=0

func _input(event):
	if event is InputEventKey and event.pressed and compareIndex<expectedInputOrder.size():
		if event.pressed and event.keycode==KEY_W:
			if expectedInputOrder[compareIndex]!="W":
				incorrectDonation()
			correctInputDetected()
		if event.pressed and event.keycode==KEY_A:
			if expectedInputOrder[compareIndex]!="A":
				incorrectDonation()
			else: 
				correctInputDetected()
		if event.pressed and event.keycode==KEY_S:
			if expectedInputOrder[compareIndex]!="S":
				incorrectDonation()
			else:
				correctInputDetected()
		if event.pressed and event.keycode==KEY_D:
			if expectedInputOrder[compareIndex]!="D":
				incorrectDonation()
			else: 
				correctInputDetected()
		

func incorrectDonation():
	print("wrong donation")
	Global.donationOnScreen=false
	self.queue_free()

func correctInputDetected():
	inputArray[compareIndex].find_child("Outline").hide()
	compareIndex+=1
	if compareIndex>=inputArray.size():
		correctDonation()
	else: 
		inputArray[compareIndex].find_child("Outline").show()

	
func correctDonation():
	print("yippie!!")
	$Notification.play("open")
	$Outline.play("open")
	#Global.donationOnScreen=false
			
func loadDonation(donationLevel):
	donationInputsBanner=find_child("DonationsBanner")
	Global.donationOnScreen=true
	$Notification.play("default")
	$Outline.play("default")
	donationLevel=3
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
	#$AnimationPlayer.speed_scale=1/2
	#$AnimationPlayer.play("timeForReaction")

	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	self.queue_free()
	


func _on_notification_animation_finished() -> void:
	if $Notification.animation == "open":
		self.queue_free()
