extends Node

const DONATION = preload("res://Scenes/Objects/Donations/donation.tscn")
@onready var TutorialVideo = $VideoFrame/Content/TutorialVideo
@export var streamer : Node2D
var firstHit = true
var hits = 0
var tactCountdown = 0
var state = 0
# 0 -> spawn prompts
# 1 -> music stopped, next tact moves over to donation
# 2 -> displaying donation tutorial for a few tacts
# 3 -> spawn donation

func _ready() -> void:
	$InputRecorder.setStreamer(streamer)
	Global.currentStreamer = streamer
	$Track.successfulHit.connect(hit)
	$MidiPlayerMusic.volume_db = -80
	$BackingTrack.setVolume(-80)
	Global.tact.connect(tact)

func hit():
	hits += 1
	if firstHit:
		firstHit = false
		$MidiPlayerMusic.volume_db = -20
		$BackingTrack.setVolume(-30)
	if state == 0 and hits > 4:
		state = 1
		tactCountdown = 2
		$Track.stopMusic()

func tact(_index):
	tactCountdown -= 1
	
	if tactCountdown <= 0:
		match(state):
			0: return
			1: TutorialVideo.play("Static")
			2: spawnDonation()

func spawnDonation():
	state = 3
	var newDonation = DONATION.instantiate()
	newDonation.position=$UI/DonationPlaceholder.position
	newDonation.loadDonation(Global.difficultyDonations)
	newDonation.fail.connect(failedDonation)
	newDonation.claimed.connect(claimedDonation)
	$UI.add_child(newDonation)

func failedDonation():
	state = 2

func claimedDonation():
	pass

func _on_animated_sprite_2d_animation_finished() -> void:
	TutorialVideo.play("DonationPrompts")
	state = 2
	tactCountdown = 2
