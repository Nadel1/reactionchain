extends Node

@onready var TutorialVideo = $VideoFrame/Content/TutorialVideo
@onready var donation = $UI/Donation
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
	$UI/Track.successfulHit.connect(hit)
	$MidiPlayerMusic.volume_db = -80
	$BackingTrack.setVolume(-80)
	Global.tact.connect(tact)
	Global.health = 0.5
	Global.updateStreamerStats.emit()
	donation.claimed.connect(claimedDonation)
	donation.fail.connect(failedDonation)

func hit():
	hits += 1
	if firstHit:
		firstHit = false
		$MidiPlayerMusic.volume_db = -20
		$BackingTrack.setVolume(-30)
	if state == 0 and hits > 4:
		state = 1
		tactCountdown = 2
		$UI/Track.stopMusic()

func tact(_index):
	tactCountdown -= 1
	
	if tactCountdown <= 0:
		match(state):
			0: return
			1: TutorialVideo.play("Static")
			2: spawnDonation()
			3: TutorialVideo.play("Static")
			4: checkMoney()
			5: TutorialVideo.play("Static")
			6: switchToGame()

func spawnDonation():
	tactCountdown = 1
	if !Global.donationOnScreen:
		donation.show()
		donation.loadDonation(Global.difficultyDonations)
		donation.playNotificationBannerAnim()

func failedDonation():
	state = 2

func claimedDonation():
	streamer.react(RT.Emotion.POG)
	state = 3
	tactCountdown = 2

func checkMoney():
	tactCountdown = 1
	if Global.moneyEarned - 10 <= 0:
		state = 5

func switchToGame():
	Global.stopMetronome()
	Global.stopMetronomeArrows()
	Global.prepareGame(true)
	
	get_tree().change_scene_to_file("res://Scenes/Stream/stream.tscn")

func _on_animated_sprite_2d_animation_finished() -> void:
	match(state):
		1:
			TutorialVideo.play("DonationPrompts")
			state = 2
			tactCountdown = 2
		3:
			TutorialVideo.play("Regeneration")
			state = 4
			tactCountdown = 1
		5:
			TutorialVideo.play("Transition")
			state = 6
			tactCountdown = 1
