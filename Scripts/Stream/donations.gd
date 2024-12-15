extends Node2D

const DONATION_INPUT=preload("res://Scenes/Objects/Donations/donationInput.tscn")
@onready var donationInputsBanner=$DonationsBanner
var donationInputKeys=["W","A","S","D"]
var sizeOfBanner=256
var expectedInputOrder=[]

func loadDonation(donationLevel):
	for i in range(0,donationLevel):
		var donationInput=DONATION_INPUT.instantiate()
		var inputString=donationInputKeys.pick_random()
		donationInput.find_child("Input").text=inputString
		expectedInputOrder.append(inputString)
		var offset= Vector2(1,0)*sizeOfBanner/donationLevel
		donationInput.position=donationInputsBanner+offset*i
