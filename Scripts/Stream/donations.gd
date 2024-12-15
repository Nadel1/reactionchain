extends Node2D

const DONATION_INPUT=preload("res://Scenes/Objects/Donations/donationInput.tscn")
var donationInputsBanner
var donationInputKeys=["W","A","S","D"]
var sizeOfBanner=256
var expectedInputOrder=[]

func loadDonation(donationLevel):
	donationInputsBanner=find_child("DonationsBanner")
	Global.donationOnScreen=true
	for i in range(0,5):
		var donationInput=DONATION_INPUT.instantiate()
		var inputString=donationInputKeys.pick_random()
		donationInput.find_child("Input").text=inputString
		add_child(donationInput)
		expectedInputOrder.append(inputString)
		var offset= Vector2(1,0)*sizeOfBanner/donationLevel
		donationInput.position=donationInputsBanner.position+offset*i
	#$AnimationPlayer.speed_scale=1/2
	#$AnimationPlayer.play("timeForReaction")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	self.queue_free()
	
