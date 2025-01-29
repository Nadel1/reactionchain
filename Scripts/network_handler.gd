extends Node

var socket = WebSocketPeer.new()
var connectionAttempt = 0
#whether or not the global scoreboard was retrieved and is ready 
var scoreboardReady = false
var scoreboard : String

signal scoreboardAvailable
signal offline
#Ok, erstmal ne socke anziehen
func _ready() -> void:
	if !socket.connect_to_url(Global.url):
		print("[Network Node] initial connection attempt failed. Retrying two more times...")
		connectionAttempt += 1
		$ConnectionTimeoutTimer.start()
	else:
		print("[Network Node] Connected to Scoreboard Server. Requesting Scoreboard.")
		requestScoreboard()

#Frag nach dem Scoreboard brudi! Macht die Node automatisch aber kann
#auch aktiv von Aussen getriggert werden
func requestScoreboard():
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("[Network Node] Trying to request scoreboard but not connected!")
	else:
		#Do not change this, otherwise server will not respond
		#Make sure that '?' is a forbidden character for the scoreboard usernames
		socket.send_text("?GetScoreboard?") 
		print("[Network Node] Socket requested Scoreboard.")

#Gibt, falls vorhanden, das Scoreboard zurück. Ansonsten empty String.
func getScoreboard() -> String:
	if scoreboardReady:
		return scoreboard
	else:
		print("[Network Node] Was asked for scoreboard but no scoreboard received from server yet.")
		#gewünschtes Error handling hier reinhauen
		return ""

#Sende dem server ein ge-updatetes scoreboard
func sendNewHighscore(scoreboard : String):
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		print("[Network Node] Trying to send new highscore but not connected!")
	else:
		#No format checking in the Network Node. This String has to be correct.
		socket.send_text("?Scoreboard?"+scoreboard)
		print("Socket sent: "+scoreboard)


#Lass jedes mal nachgucken ob jemand was gesagt hat
func _process(_delta: float) -> void:
	socket.poll()
	
	if  socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			var msg = socket.get_packet().get_string_from_utf8()
			print("[Network Node] Socket received: "+msg)
			scoreboard = msg.erase(2,12)
			print("[Network Node] Scoreboard is: \n"+scoreboard)
			scoreboardReady = true
			scoreboardAvailable.emit()

#DEBUG. AUF JEDEN FALL AUSKOMMENTIERT LASSEN
#func _input(event):
#	if Input.is_action_just_pressed("ui_up"):
#		sendNewHighscore("Lupus,100\nLorem,99\nIpsum,98\n")
#	if Input.is_action_just_pressed("ui_down"):
#		sendNewHighscore("Patrick,111\nSponge,19\nPoo,3\n")
#	if Input.is_action_just_pressed("ui_accept"):
#		requestScoreboard()
		

#so socken muss man auch mal ausziehen digga
func _exit_tree() -> void:
	print('closing socket')
	socket.close()


func _on_timer_timeout() -> void:
	if connectionAttempt < 3:
		if !socket.connect_to_url(Global.url):
			print("[Network Node] initial connection attempt failed...")
			connectionAttempt += 1
			$ConnectionTimeoutTimer.start()
		else:
			print("[Network Node] Connected to Scoreboard Server. Requesting Scoreboard.")
			requestScoreboard()
	else:
		offline.emit()
		print("[Network Node] Could not connect to scoreboard server.. self-destructing now...")
		call_deferred("queue_free")
